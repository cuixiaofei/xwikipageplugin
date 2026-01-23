package pageplugin.internal;

import pageplugin.PdfHashService;

import java.security.MessageDigest;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

/**
 * PDF哈希服务的默认实现
 * 使用SHA-256算法，拼接pdfBytes + "|" + userSeed
 */
public class DefaultPdfHashService implements PdfHashService {
    
    private static final Gson gson = new Gson();
    
    @Override
    public String hashPdfWithIdentity(byte[] pdfBytes, String userSeed) {
        try {
            // Step 1: 拼接 pdfBytes + "|" + userSeed
            String delimiter = "|";
            byte[] seedBytes = userSeed.getBytes("UTF-8");
            byte[] delimiterBytes = delimiter.getBytes("UTF-8");
            
            byte[] combined = new byte[pdfBytes.length + delimiterBytes.length + seedBytes.length];
            System.arraycopy(pdfBytes, 0, combined, 0, pdfBytes.length);
            System.arraycopy(delimiterBytes, 0, combined, pdfBytes.length, delimiterBytes.length);
            System.arraycopy(seedBytes, 0, combined, pdfBytes.length + delimiterBytes.length, seedBytes.length);
            
            // Step 2: SHA-256哈希
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(combined);
            
            // Step 3: 转换为十六进制字符串
            StringBuilder hexString = new StringBuilder("0x");
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) {
                    hexString.append('0');
                }
                hexString.append(hex);
            }
            
            // Step 4: 构建JSON响应
            JsonObject result = new JsonObject();
            result.addProperty("hash", hexString.toString());
            result.addProperty("userSeed", userSeed);
            result.addProperty("size", pdfBytes.length);
            
            return gson.toJson(result);
            
        } catch (Exception e) {
            throw new RuntimeException("PDF哈希生成失败", e);
        }
    }
}
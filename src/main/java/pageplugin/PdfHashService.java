package pageplugin;

/**
 * PDF哈希服务接口，为文档提供基于用户身份的哈希生成
 * 符合NSG-Plugin Phase1任务书规范
 */
public interface PdfHashService {
    /**
     * 生成带用户身份标识的PDF哈希值
     * 
     * @param pdfBytes PDF文件字节数组
     * @param userSeed 用户身份标识字符串
     * @return JSON格式字符串 {"hash": "0x...", "userSeed": "...", "size": 12345}
     */
    String hashPdfWithIdentity(byte[] pdfBytes, String userSeed);
}
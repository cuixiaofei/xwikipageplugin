package pageplugin.internal;

import org.p2p.solanaj.core.Account;
import org.p2p.solanaj.core.Transaction;
import org.p2p.solanaj.programs.MemoProgram;
import org.p2p.solanaj.rpc.RpcClient;
import org.p2p.solanaj.rpc.RpcException;

import com.google.gson.Gson;
import com.google.gson.JsonObject;

import io.github.novacrypto.base58.Base58;
import pageplugin.SolanaService;

/**
 * Solana服务的默认实现
 * 使用solanaj SDK发送Memo交易到Devnet
 * 适配API 1.24.0版本
 */
public class DefaultSolanaService implements SolanaService {
    
    private static final Gson gson = new Gson();
    private final RpcClient client;
    private final Account payer;
    private final boolean isMockMode;

    public DefaultSolanaService() {
        String rpcUrl = System.getProperty("solana.rpc.url", "https://api.devnet.solana.com");
        this.client = new RpcClient(rpcUrl);
        
        String privateKeyBase58 = System.getProperty("solana.private.key");
        if (privateKeyBase58 == null || privateKeyBase58.isEmpty()) {
            privateKeyBase58 = System.getenv("SOLANA_PRIVATE_KEY");
        }
        
        if (privateKeyBase58 == null || privateKeyBase58.isEmpty()) {
            // ✅ 模拟模式：创建随机账户
            this.payer = new Account();
            this.isMockMode = true;
            System.out.println("⚠️ 未配置SOLANA_PRIVATE_KEY，启用模拟模式");
        } else {
            // 真实模式：解码Base58私钥
            byte[] privateKeyBytes = Base58.base58Decode(privateKeyBase58);
            this.payer = new Account(privateKeyBytes);
            this.isMockMode = false;
        }
    }
    
    @Override
    public String sendHashToSolana(String hashHex) {
        try {
            if (isMockMode) {
                // 模拟模式：返回模拟txid
                String mockTxid = "mock-tx-" + System.currentTimeMillis();
                JsonObject result = new JsonObject();
                result.addProperty("txid", mockTxid);
                result.addProperty("explorer", "https://solscan.io/tx/" + mockTxid + "?cluster=devnet");
                return gson.toJson(result);
            }
            
            // 真实模式：发送交易到Solana
            Transaction transaction = new Transaction();
            transaction.addInstruction(MemoProgram.writeUtf8(payer.getPublicKey(), hashHex));
            String txid = client.getApi().sendTransaction(transaction, payer, "confirmed");
            
            JsonObject result = new JsonObject();
            result.addProperty("txid", txid);
            result.addProperty("explorer", "https://solscan.io/tx/" + txid + "?cluster=devnet");
            return gson.toJson(result);
            
        } catch (RpcException e) {
            throw new RuntimeException("Solana交易失败: " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("Unexpected error", e);
        }
    }
}
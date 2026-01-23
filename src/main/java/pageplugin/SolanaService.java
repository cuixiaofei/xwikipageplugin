package pageplugin;

/**
 * Solana区块链服务接口，提供哈希上链存证功能
 * 符合NSG-Plugin Phase1任务书规范
 */
public interface SolanaService {
    /**
     * 将哈希值发送到Solana Devnet（空交易+Memo）
     * 
     * @param hashHex 十六进制格式的哈希字符串
     * @return JSON格式字符串 {"txid": "5o46V...", "explorer": "https://solscan.io/tx/..."}
     */
    String sendHashToSolana(String hashHex);
}
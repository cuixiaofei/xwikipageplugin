package pageplugin;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertTrue;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import pageplugin.internal.DefaultSolanaService;

/**
 * Phase1 Step2: Solana上链测试
 * 验证SolanaService接口的正确性
 */
public class Step2Test {
    
    private SolanaService solanaService;
    private boolean isMockMode;
    
    @BeforeEach
    public void setUp() {
        String privateKeyBase58 = System.getProperty("solana.private.key");
        if (privateKeyBase58 == null || privateKeyBase58.isEmpty()) {
            privateKeyBase58 = System.getenv("SOLANA_PRIVATE_KEY");
        }
        this.isMockMode = (privateKeyBase58 == null || privateKeyBase58.isEmpty());
        
        solanaService = new DefaultSolanaService();
    }
    
    @Test
    public void testSendHashToSolana() {
        String resultJson = solanaService.sendHashToSolana("0x1234567890abcdef");
        
        assertNotNull(resultJson);
        com.google.gson.JsonObject result = com.google.gson.JsonParser.parseString(resultJson).getAsJsonObject();
        
        String txid = result.get("txid").getAsString();
        String explorer = result.get("explorer").getAsString();
        
        assertNotNull(txid);
        assertTrue(explorer.startsWith("https://solscan.io/tx/"));
        
        // ✅ 修复：根据模式验证txid格式
        if (isMockMode) {
            // 模拟模式：mock-tx-开头的任意长度
            assertTrue(txid.startsWith("mock-tx-"), "模拟模式应包含mock-tx-前缀");
            System.out.println("✅ Step2Test PASSED (MOCK MODE)");
            System.out.println("📄 Mock Transaction: " + txid);
        } else {
            // 真实模式：Base58格式，长度64-88
            assertTrue(txid.length() >= 64 && txid.length() <= 88, 
                      "真实txid长度应在64-88之间");
            System.out.println("✅ Step2Test PASSED (REAL TRANSACTION)");
            System.out.println("🚀 Transaction ID: " + txid);
            System.out.println("🔍 Explorer: " + explorer);
        }
    }
}
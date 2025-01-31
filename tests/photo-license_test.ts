import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test photo registration",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        
        let block = chain.mineBlock([
            Tx.contractCall('photo-license', 'register-photo', [
                types.uint(100),
                types.ascii("Test Photo"),
                types.ascii("Test Description")
            ], deployer.address)
        ]);

        block.receipts[0].result.expectOk();
        assertEquals(block.receipts[0].result, types.ok(types.uint(1)));
    }
});

Clarinet.test({
    name: "Test license purchase",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const buyer = accounts.get('wallet_1')!;
        
        // First register a photo
        let block1 = chain.mineBlock([
            Tx.contractCall('photo-license', 'register-photo', [
                types.uint(100),
                types.ascii("Test Photo"),
                types.ascii("Test Description")
            ], deployer.address)
        ]);

        // Then purchase a license
        let block2 = chain.mineBlock([
            Tx.contractCall('photo-license', 'purchase-license', [
                types.uint(1),
                types.ascii("Standard License Terms"),
                types.uint(100)
            ], buyer.address)
        ]);

        block2.receipts[0].result.expectOk();
    }
});

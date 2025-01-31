import {
    Clarinet,
    Tx,
    Chain,
    Account,
    types
} from 'https://deno.land/x/clarinet@v1.0.0/index.ts';
import { assertEquals } from 'https://deno.land/std@0.90.0/testing/asserts.ts';

Clarinet.test({
    name: "Test photo registration with category and collaborators",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const collaborator = accounts.get('wallet_2')!;
        
        // Add category first
        let block1 = chain.mineBlock([
            Tx.contractCall('photo-license', 'add-category', [
                types.ascii("nature")
            ], deployer.address)
        ]);
        
        let block2 = chain.mineBlock([
            Tx.contractCall('photo-license', 'register-photo', [
                types.uint(100),
                types.ascii("Test Photo"),
                types.ascii("Test Description"),
                types.ascii("nature"),
                types.list([{
                    address: collaborator.address,
                    share: types.uint(20)
                }])
            ], deployer.address)
        ]);

        block2.receipts[0].result.expectOk();
        assertEquals(block2.receipts[0].result, types.ok(types.uint(1)));
    }
});

Clarinet.test({
    name: "Test commercial license purchase with revenue sharing",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const buyer = accounts.get('wallet_1')!;
        const collaborator = accounts.get('wallet_2')!;
        
        // Setup category and photo
        let block1 = chain.mineBlock([
            Tx.contractCall('photo-license', 'add-category', [
                types.ascii("nature")
            ], deployer.address),
            Tx.contractCall('photo-license', 'register-photo', [
                types.uint(100),
                types.ascii("Test Photo"),
                types.ascii("Test Description"),
                types.ascii("nature"),
                types.list([{
                    address: collaborator.address,
                    share: types.uint(20)
                }])
            ], deployer.address)
        ]);

        // Purchase commercial license
        let block2 = chain.mineBlock([
            Tx.contractCall('photo-license', 'purchase-license', [
                types.uint(1),
                types.ascii("Commercial License Terms"),
                types.uint(100),
                types.bool(true)
            ], buyer.address)
        ]);

        block2.receipts[0].result.expectOk();
    }
});

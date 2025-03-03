Clarinet.test({
    name: "Test license renewal functionality with various scenarios",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const buyer = accounts.get('wallet_1')!;
        
        // Test valid duration renewal
        let block1 = chain.mineBlock([
            Tx.contractCall('photo-license', 'renew-license', [
                types.uint(1),
                types.uint(100)
            ], buyer.address)
        ]);
        block1.receipts[0].result.expectOk();

        // Test invalid duration (too long)
        let block2 = chain.mineBlock([
            Tx.contractCall('photo-license', 'renew-license', [
                types.uint(1),
                types.uint(52561)
            ], buyer.address)
        ]);
        block2.receipts[0].result.expectErr(108); // err-invalid-duration

        // Test expired license renewal
        // [Additional test cases]
    }
});

// [Previous tests remain unchanged]

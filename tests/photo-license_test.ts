// [Previous imports remain unchanged]

Clarinet.test({
    name: "Test license renewal functionality",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get('deployer')!;
        const buyer = accounts.get('wallet_1')!;
        
        // Setup and initial license purchase
        // [Setup code similar to previous tests]
        
        // Renew license
        let block3 = chain.mineBlock([
            Tx.contractCall('photo-license', 'renew-license', [
                types.uint(1),
                types.uint(100)
            ], buyer.address)
        ]);

        block3.receipts[0].result.expectOk();
    }
});

// [Previous tests remain unchanged]

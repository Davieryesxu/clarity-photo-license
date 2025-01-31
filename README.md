# Decentralized Photography Licensing System

A blockchain-based system for managing photography licenses built on the Stacks blockchain using Clarity.

## Features

- Photographers can register their photos with custom pricing
- Support for multiple photo categories and content organization
- Revenue sharing between multiple collaborators with validation
- Commercial and non-commercial licensing options
- Platform fee structure for sustainability
- Users can purchase time-limited licenses for photos
- All transactions and license ownership recorded on-chain
- Automatic payment distribution to photographers and collaborators
- Transparent license terms and history

## Technical Details

The system uses the following main functions:
- register-photo: For photographers to list their work with categories and collaborators
- purchase-license: For users to buy commercial or non-commercial licenses
- add-category: For admin to manage content categories
- get-photo-details: To view photo information
- get-license-details: To verify license ownership
- get-categories: To view available photo categories

### Revenue Sharing
- Platform takes 5% fee on all transactions
- Support for up to 5 collaborators per photo
- Automatic payment distribution based on share percentages
- Collaborator shares are validated to not exceed 100%
- Owner receives remaining share after collaborator distributions
- Commercial licenses cost 2x regular price

## Getting Started

1. Clone the repository
2. Install Clarinet
3. Run `clarinet console` to interact with the contract
4. Run `clarinet test` to run the test suite

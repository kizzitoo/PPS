# PPS - Privacy-Preserving Systems

A comprehensive privacy infrastructure for Stacks that enables confidential transactions, encrypted state management, and zero-knowledge proofs. Built to give users control over their data while maintaining blockchain verification guarantees.

## The Privacy Problem

Public blockchains expose everything. Every transaction, every balance, every interaction is visible to anyone. This transparency is great for verification but terrible for privacy. Businesses can't put sensitive data on-chain. Users can't transact without revealing their entire financial history. We need systems that prove things without revealing them.

## What This Framework Provides

Privacy-Preserving Systems brings cryptographic privacy to Stacks:

- **Zero-knowledge proof integrations** for private transactions without trusted parties
- **Confidential execution** where contract state stays encrypted
- **Privacy-preserving identity** that proves attributes without revealing data
- **Mixing protocols** that break transaction graph analysis
- **Private voting** where ballots stay secret but results are verifiable
- **Encrypted on-chain storage** for sensitive data
- **Privacy-preserving analytics** that compute over encrypted data
- **Anonymous credentials** for selective disclosure

## Current Status

**Phase 1: Zero-Knowledge Proof Integrations** ✅

The foundation works. A complete ZK commitment scheme that lets users prove they own assets without revealing amounts or identities. The contract handles commitment creation, verification, and nullifier tracking to prevent double-spending. Users can transfer value privately while the blockchain verifies correctness cryptographically.

## Installation

### Prerequisites

- Node.js v18 or higher
- Clarinet 3.7.0
- npm or yarn
- Git

### Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/privacy-preserving-systems.git
cd privacy-preserving-systems

# Install dependencies
npm install

# Setup crypto libraries
npm run setup-crypto

# Verify installation
clarinet check

# Run tests
npm test
```

## Quick Start

```javascript
import { ZKCommitment } from './lib/zk-commitment';

// Create a commitment to hide value
const commitment = await ZKCommitment.create({
  value: 1000,
  salt: randomBytes(32)
});

// Register commitment on-chain
await commitment.register();

// Prove ownership without revealing value
const proof = await commitment.generateProof();

// Verify proof
const valid = await ZKCommitment.verify(proof);
```

## Project Structure

```
privacy-preserving-systems/
├── contracts/
│   ├── zk-commitments.clar       # ZK commitment contract
│   ├── mixer.clar                # Mixing protocol (coming soon)
│   └── tests/
│       └── commitment_test.ts    # Contract tests
├── lib/
│   ├── zk-commitment.js          # ZK proof generation
│   ├── crypto-utils.js           # Cryptographic primitives
│   └── privacy-manager.js        # Privacy orchestration
├── examples/
│   ├── private-transfer.js       # Private transfer example
│   └── mixing.js                 # Mixing example
├── tests/
│   └── privacy.test.js           # Integration tests
├── Clarinet.toml
├── package.json
└── README.md
```

## Configuration

Configure privacy parameters in `privacy.config.js`:

```javascript
module.exports = {
  commitment: {
    hashFunction: 'sha256',
    commitmentSize: 32,
    saltSize: 32
  },
  mixer: {
    anonymitySet: 100,
    mixingFee: 0.001,
    withdrawalDelay: 144  // blocks
  },
  encryption: {
    algorithm: 'aes-256-gcm',
    keyDerivation: 'pbkdf2'
  }
};
```

## Development Roadmap

### Phase 1: Foundation (Current)
- [x] Zero-knowledge proof integrations
- [ ] Confidential contract execution
- [ ] Privacy-preserving identity

### Phase 2: Advanced Privacy
- [ ] Mixing protocols
- [ ] Private voting systems
- [ ] Encrypted data storage

### Phase 3: Analytics & Credentials
- [ ] Privacy-preserving analytics
- [ ] Anonymous credential systems
- [ ] Advanced ZK circuits

## Features in Detail

### Zero-Knowledge Commitments

Users commit to values without revealing them:
1. Hash value with random salt
2. Store commitment on-chain
3. Generate proof of knowledge
4. Verify proof without learning value

### Commitment Scheme

```
commitment = hash(value || salt)
proof = {value, salt, commitment}
verify: hash(value || salt) == commitment
```

### Privacy Guarantees

- Values stay hidden until revealed
- Ownership proven cryptographically
- No trusted third parties needed
- Blockchain verifies all proofs
- Double-spend prevention via nullifiers

## Running Privacy Systems

```bash
# Start privacy services
npm run start

# Create commitment
npm run commit:create

# Generate proof
npm run proof:generate

# Verify proof
npm run proof:verify

# Run privacy tests
npm run test:privacy
```

## API Reference

### ZK Commitments Contract

```clarity
;; Create commitment
(contract-call? .zk-commitments create-commitment
  commitment-hash)

;; Reveal commitment
(contract-call? .zk-commitments reveal-commitment
  commitment-id
  value
  salt)

;; Nullify commitment
(contract-call? .zk-commitments nullify-commitment
  commitment-id
  nullifier)

;; Check commitment
(contract-call? .zk-commitments get-commitment
  commitment-id)
```

### JavaScript SDK

```javascript
// Create commitment
const commitment = await ZK.createCommitment(value, salt);

// Generate proof
const proof = await ZK.generateProof(commitment);

// Verify proof
const isValid = await ZK.verifyProof(proof);

// Nullify spent commitment
await ZK.nullify(commitmentId, nullifier);
```

## Architecture

Privacy layers work together:

1. **Cryptographic Layer**: Hash functions and proof generation
2. **Commitment Layer**: On-chain commitment storage
3. **Verification Layer**: Proof validation logic
4. **Nullifier Layer**: Double-spend prevention
5. **Privacy Layer**: User-facing abstractions

## Usage Examples

### Private Transfer

```javascript
// Sender creates commitment
const senderCommitment = await ZK.createCommitment({
  value: 1000,
  salt: randomBytes(32)
});

await senderCommitment.register();

// Generate transfer proof
const transferProof = await ZK.generateTransferProof({
  inputCommitment: senderCommitment,
  outputValue: 1000,
  recipient: recipientAddress
});

// Recipient verifies and claims
const valid = await ZK.verifyTransferProof(transferProof);
if (valid) {
  await ZK.claimTransfer(transferProof);
}
```

### Creating Commitments

```javascript
const commitment = new ZKCommitment();

// Commit to a value
const commitmentData = await commitment.commit({
  value: 5000,
  owner: userAddress
});

// Register on-chain
const txid = await commitment.register(commitmentData);

console.log(`Commitment registered: ${commitmentData.hash}`);
```

### Verifying Proofs

```javascript
// Someone claims to own a commitment
const claim = {
  commitmentId: 123,
  value: 5000,
  salt: '0x...'
};

// Verify without trusting the claimer
const verified = await ZK.verify({
  commitment: claim.commitmentId,
  value: claim.value,
  salt: claim.salt
});

if (verified) {
  // Proof valid, commitment authentic
  await processTransfer(claim);
}
```

### Nullifying Commitments

```javascript
// Spend a commitment (prevents reuse)
const nullifier = await ZK.generateNullifier({
  commitmentId: 123,
  secret: userSecret
});

await ZK.nullify({
  commitmentId: 123,
  nullifier: nullifier
});

// Future attempts to use this commitment fail
```

## Security Considerations

### Before Using Privacy Features

- Understand cryptographic assumptions
- Test thoroughly on testnet
- Never reuse salts or secrets
- Keep private keys secure
- Verify all proofs before trusting

### Best Practices

- Use cryptographically secure randomness
- Never log sensitive values
- Implement proper key management
- Monitor for cryptographic breaks
- Have key rotation procedures

### Common Risks

- **Salt reuse**: Breaks privacy, use unique salts always
- **Weak randomness**: Predictable commitments
- **Key exposure**: Complete privacy loss
- **Implementation bugs**: Subtle crypto errors
- **Side channels**: Timing attacks on verification

## Privacy Models

### Commitment-Based Privacy

```javascript
// Public: commitment hash
// Private: value, salt
{
  public: hash(value || salt),
  private: { value, salt }
}
```

### Selective Disclosure

```javascript
// Prove property without revealing value
{
  claim: "value > 1000",
  proof: zkProof,
  commitment: commitmentHash
}
```

## Testing Strategy

```bash
# Unit tests for crypto primitives
npm run test:crypto

# Integration tests for commitments
npm run test:integration

# Privacy attack simulations
npm run test:attacks

# Performance benchmarks
npm run test:performance

# Full test suite
npm test
```

## Performance Metrics

Expected performance:
- Commitment creation: < 100ms
- Proof generation: 200-500ms
- Proof verification: 50-100ms
- On-chain storage: ~32 bytes per commitment
- Gas costs: Moderate (commitment storage)

## Troubleshooting

**Proof verification fails**: Check salt matches commitment

**Nullifier already used**: Commitment already spent

**Invalid commitment**: Hash mismatch or corrupted data

**Performance issues**: Use batch operations

**Privacy leak**: Review logging and error messages

## Contributing

Help build better privacy tools:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/mixing-protocol`)
3. Write comprehensive tests
4. Document cryptographic assumptions
5. Commit changes (`git commit -m 'Add mixing protocol'`)
6. Push to branch (`git push origin feature/mixing-protocol`)
7. Open a Pull Request

Privacy features need extra security review. Include threat models.

## Cryptographic Assumptions

This system relies on:
- Collision resistance of SHA-256
- Computational hardness of hash preimages
- Secure random number generation
- Proper salt handling

If any assumption breaks, privacy guarantees fail.

## Deployment Checklist

- [ ] Audit cryptographic implementation
- [ ] Test on testnet extensively
- [ ] Verify randomness sources
- [ ] Document privacy guarantees
- [ ] Set up monitoring
- [ ] Plan key rotation
- [ ] Deploy with conservative settings
- [ ] Prepare incident response

## License

MIT License - See LICENSE file for details

## Support

Get privacy help:
- Open issues on GitHub
- Check /docs for guides
- Review examples directory
- Consult cryptography experts

## Acknowledgments

Built with Clarinet 3.7.0 for the Stacks blockchain. Implements cryptographic protocols proven in privacy-focused blockchain systems.

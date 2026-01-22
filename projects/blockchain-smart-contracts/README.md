# Blockchain Smart Contracts (Solidity)

University project for the **Mobile and Wireless Communications Security** course.  
Includes two Solidity contracts and a short report with design notes and auditing discussion.

## Contents
- `UserData.sol` — role-based registry (owner/teacher/student), grade updates, and per-user access control for viewing data.
- `VotingStudent.sol` — “PresidentialElection” voting contract (candidate registration, one vote per address, winner computation).
- `Blockchain_Report.pdf` — project report and analysis.

## How to run (quick test with Remix)
1. Open https://remix.ethereum.org
2. Upload the `.sol` files into Remix.
3. Compile with a Solidity `0.8.x` compiler.
4. Deploy in **Deploy & Run Transactions** and test using multiple accounts.

## Demo flows

### UserData
- Deploy as **owner**
- Owner registers a teacher
- Teacher registers students + updates grades
- Students can grant/revoke access to their own data

### PresidentialElection
- Deploy
- Register candidates (self or by owner)
- Vote (each address once)
- Check winner / summary

## Notes
- Educational project; not audited for production use.
- Avoid storing real personal data on-chain in real deployments (blockchain storage is publicly readable). 

🟇
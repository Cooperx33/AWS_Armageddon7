# AWS_Armageddon7
This is the submission area for the Class 7 Armageddon



                                ========Questions====

A Why is DB inbound source restricted to the EC2 security group?
    Its restricted so that the DB is only reachable to those allowed in said (SG) no one else. Preventing exopsure to random IP's... Its identity-based access, not IP based Acess like a type of stateful Firewall. 

B What port does MySQL use?
    Port 3306 by default for all stamdard client-server communication


C Why is Secrets Manager better than storing creds in code/user-data?
    Its a massive upgrade in security and flexibility by...
    1 Automatic Rotation without touching an app using Lamda rotation hooks
    2 Encrypts everything with "KMS" Key management System
    3 Keeps secrets out of the codebase entirely, so if code leaks... your secrets dont
    4 Fine grained IAM access control

                                    WHY?????

Why each rule exists?

    DB Inbound Rule restricted to the EC2 SG
    1 To ensure only the app servers can talk to the Databse
    2 To prevent any other VPC instance from connecting
    3 To enforce Tier Isolation (web - app - DB)
    4 To support AutoScaling without updating IP's

    Secrets Manager
    1 To prevent leaks from Git, Logs, Ami's or user data
    2 To allow automatic rotation without deploying anything
    3 To provide Audit Logs
    4 To eliminate static, hardcoded, unrotatable credentials

    Never store secrets in COde/Userdata
    1 User-data is plaintext it gets logged by cloud-init
    2 User-data is not a secure channel any instance can curl metadata and read it
    3 Code gets copied, cloned, zipped, e-mailed and backed up
    4 Secrets become tied to the deployment lifecycle
    5 COde is not a Safe or Controlled environment

    IAM roles
    1 Roles provide temporary credentials
    2 they rotate automatically
    3 they eliminate the need for long-lived keys
    4 To remove static access keys entirely

    Security Goups
    1 To simplify network rules
    2 To avoid needing matching outbound rules
    3 To reduce misconfiguration
    4 To make network secruty simpler and safer


What would break if removed?
    
  1) The application will break if the DB inbound rule that restricts access to EC2 is removed
  2) If Secrets Manager is removed Credential rotation would break casusing relaunch of instances every time
  3) If "never store secrets in user-data" is removed anyone can curl metadata
  4) If IAM roles are removed anyone with the key has full access until manually revoked
  5) If SG's are removed network traffic would be Hell and would need matching inbound/outbound rules for every connection
  6) If SG to SG is removed Auto-scaling would break


Why broader access is forbidden?
    1 Broader access increases the number of potential attacker
    2 Increases the blast radius of a breach
    3 Makes misconfiguration more dangerous
    4 Breaks the principle of least privilage


Why this role exists?
    It exists to let a resource access something securely without givin it permanent credentials & lets AWS identify who is making a request.


Why it can read this secret?
 It has an allow policy for that secret and that secret's own resource policy allows that role to access it

Why it cannot read others?
    A resource can read one secret but not others because AWS layers multiple controls that all must agree before access is granted. If any layers say "no" the request is denied.
 c215421 (Lab1A)

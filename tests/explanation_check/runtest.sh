. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlRun 'cat >test_avc <<EOF
type=AVC msg=audit(1516626432.810:3461): avc:  denied  { write } for  pid=4310 comm="test" path="/root/test" ino=8619937 scontext=system_u:system_r:sssd_t:s0-s0:c0.c1023 tcontext=system_u:object_r:bin_t:s0 tclass=file permissive=0
type=AVC msg=audit(1516626657.910:4461): avc:  denied  { open } for  pid=4310 comm="test" path="/root/test" ino=8619937 scontext=system_u:system_r:sssd_t:s0-s0:c0.c1023 tcontext=system_u:object_r:bin_t:s0 tclass=file permissive=0
EOF'
    rlPhaseEnd

    rlPhaseStartTest
        # first AVC is denied, second one is allowed so instead of showing one
        # rule with '{open write}' permissions, the rules should be on separate
        # lines
        rlRun "audit2allow <test_avc"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "rm test_avc"
    rlPhaseEnd
rlJournalEnd

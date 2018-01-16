. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test_module.te" || rlDie

        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"

        rlRun "gcc test.c -o test -lselinux"

        # assign all nodes default context 'my_node_t'
        rlRun "semanage node -a -t my_node_t -M 0.0.0.0 0.0.0.0 -p ipv4"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        # run test program with context 'my_test_domain_t' and try to bind
        # to a node
        rlRun "runcon -t my_test_domain_t ./test > output" 1
        rlRun "cat output"

        # check context of the process
        rlRun "grep 'getcon: unconfined_u:unconfined_r:my_test_domain_t:s0-s0:c0.c1023' output"
        # check that the process failed on bind()
        rlRun "grep 'bind(...) = -1' output"

        rlRun "sealert -l '*'"

        # there should be AVC message that node_bind was denied
        rlRun "ausearch -m avc | grep 'denied  { node_bind }'"

        rlRun "ausearch -m avc | audit2allow"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semanage node -d -t my_node_t -M 0.0.0.0 0.0.0.0 -p ipv4"
        rlRun "semodule -r test_module"
        rlRun "rm test output test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

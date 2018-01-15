. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test.c" || rlDie
        rlAssertExists "test_module.te" || rlDie

        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"

        rlRun "gcc test.c -o test -lselinux"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        # run test program with context 'my_test_domain_t' and try to bind
        # tcp port 14
        rlRun "runcon -t my_test_domain_t ./test 14 > output" 1
        rlRun "cat output"

        # check context of the process
        rlRun "grep 'getcon: unconfined_u:unconfined_r:my_test_domain_t:s0-s0:c0.c1023' output"
        # check that the process failed on bind()
        rlRun "grep 'bind(...) = -1' output"

        # there should be AVC message that name_bind was denied
        rlRun "ausearch -m avc | grep 'denied  { name_bind }'"

        # audit2allow should not provide allow rule, my_test_domain_t would gain
        # access to all reserved ports
        rlRun "ausearch -m avc | audit2allow | grep 'allow my_test_domain_t reserved_port_t:tcp_socket name_bind;'" 1

        # audit2allow should provide semanage port command
        # 
        #   semanage port -a -t my_test_domain_t -p tcp 14
        #
        rlRun "ausearch -m avc | audit2allow | grep 'semanage port'"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        # label the port using semanage port command
        rlRun "semanage port -a -t my_test_domain_port_t -p tcp 14"

        # run test program, it should now succeed
        rlRun "runcon -t my_test_domain_t ./test 14 > output" 0
        rlRun "cat output"

        # check context of the process
        rlRun "grep 'getcon: unconfined_u:unconfined_r:my_test_domain_t:s0-s0:c0.c1023' output"
        # check that the process did not fail on bind()
        rlRun "grep 'bind(...) = 0' output"

        # there should not be any AVC messages
        rlRun "ausearch -m avc" 1
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semanage port -d -p tcp 14"
        rlRun "semodule -r test_module"
        rlRun "rm output test test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

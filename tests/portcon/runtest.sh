. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test.c" || rlDie
        rlAssertExists "test_module.te" || rlDie

        rlRun "gcc test.c -o test"

        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        rlRun "semanage port -a -t my_test_port_t -p tcp 12345"

        rlRun "semanage port -l | grep 12345 | grep my_test_port_t"

        rlRun "./test 12345"

        rlRun "ausearch -m avc"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semanage port -d -p tcp 12345"
        rlRun "semodule -r test_module"
        rlRun "rm test test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

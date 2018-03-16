. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test.c" || rlDie
        rlAssertExists "test_module.te" || rlDie

        rlRun "which audit2allow"

        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"

        rlRun "checkmodule -m -M test_module2.te -o test_module2.mod"
        rlRun "semodule_package -m test_module2.mod -o test_module2.pp"

        rlRun "gcc test.c -o test"

        rlRun "touch testfile"
        rlRun "chcon -t my_test_file_t testfile"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        rlRun "./test testfile 0x1234" 1

        rlRun "ausearch -m avc | grep 'ioctlcmd=0x1234'"

        rlRun "ausearch -m avc | python $(which audit2allow)"

        rlRun "semodule -i test_module2.pp"

        rlRun "ausearch -m avc | python $(which audit2allow)"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semodule -r test_module2"
        rlRun "semodule -r test_module"
        rlRun "rm test testfile test_module.pp test_module.mod"
        rlRun "rm test_module2.pp test_module2.mod"
    rlPhaseEnd
rlJournalEnd

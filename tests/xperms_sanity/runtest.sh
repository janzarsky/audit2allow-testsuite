. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test.c" || rlDie
        rlAssertExists "test_module.te" || rlDie

        rlRun "which audit2allow"

        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"

        rlRun "gcc test.c -o test"
        rlRun "touch testfile"

        rlRun "chcon -t my_test_file_t testfile"

        rlRun "ls -lZ"
    rlPhaseEnd

    rlPhaseStartTest "Denied ioctl number"
        rlRun "true >/var/log/audit/audit.log"

        rlRun "./test testfile 0x42" 1

        rlRun "ausearch -m avc | grep 'ioctlcmd=0x42'"

        rlRun "ausearch -m avc | python $(which audit2allow) | grep -C 999 allowxperm"
    rlPhaseEnd

    rlPhaseStartTest "Allowed ioctl number"
        rlRun "true >/var/log/audit/audit.log"

        rlRun "./test testfile 0x8927" 0

        rlRun "ausearch -m avc | grep 'ioctlcmd'" 1
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semodule -r test_module"
        rlRun "rm test testfile test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

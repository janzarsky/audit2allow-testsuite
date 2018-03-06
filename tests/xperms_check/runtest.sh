. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test.c" || rlDie
        rlAssertExists "test_module.te" || rlDie

        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"

        rlRun "gcc test.c -o test"
        rlRun "touch testfile"

        rlRun "chcon -t my_test_file_t testfile"

        rlRun "ls -lZ"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        rlRun "./test testfile 0x10" 0
        rlRun "./test testfile 0x20" 0
        rlRun "./test testfile 0x30" 1
        rlRun "./test testfile 0x40" 0
        rlRun "./test testfile 0x50" 0

        rlRun "ausearch -m avc | grep 'ioctlcmd=0x10'" 1
        rlRun "ausearch -m avc | grep 'ioctlcmd=0x20'" 1
        rlRun "ausearch -m avc | grep 'ioctlcmd=0x30'" 0
        rlRun "ausearch -m avc | grep 'ioctlcmd=0x40'" 1
        rlRun "ausearch -m avc | grep 'ioctlcmd=0x50'" 1
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semodule -r test_module"
        rlRun "rm test testfile test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

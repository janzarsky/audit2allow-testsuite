. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test.c" || rlDie
        rlAssertExists "test_module.te" || rlDie

        rlAssertRpm "gcc" || rlDie

        rlRun "which audit2allow"

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

        # generate AVCs
        rlRun "./test testfile 128" 1
        rlRun "./test testfile 129" 1
        rlRun "./test testfile 130" 1
        rlRun "./test testfile 132" 1

        rlRun "ausearch -m avc | grep 'ioctlcmd=0x80'"
        rlRun "ausearch -m avc | grep 'ioctlcmd=0x81'"
        rlRun "ausearch -m avc | grep 'ioctlcmd=0x82'"
        rlRun "ausearch -m avc | grep 'ioctlcmd=0x84'"

        # run audit2allow, no xperms
        rlRun "ausearch -m avc | python $(which audit2allow) | tee rules"

        rlRun "grep 'allow unconfined_t my_test_file_t:file ioctl;' rules"
        rlRun "grep 'allowxperm unconfined_t my_test_file_t:file ioctl { 128-130 132 };' rules" 1

        # run audit2allow, with xperms option
        rlRun "ausearch -m avc | python $(which audit2allow) -x | tee rules"

        rlRun "grep 'allow unconfined_t my_test_file_t:file ioctl;' rules"
        rlRun "grep 'allowxperm unconfined_t my_test_file_t:file ioctl { 128-130 132 };' rules"

        # run audit2allow, generate dontaudit rules
        rlRun "ausearch -m avc | python $(which audit2allow) -x -D | tee rules"

        rlRun "grep 'dontaudit unconfined_t my_test_file_t:file ioctl;' rules"
        rlRun "grep 'dontauditxperm unconfined_t my_test_file_t:file ioctl { 128-130 132 };' rules"

        # run audit2allow, verbose mode
        rlRun "ausearch -m avc | python $(which audit2allow) -x -v | tee rules"

        # not (yet?) supported
        # run audit2why
        #rlRun "ausearch -m avc | python $(which audit2allow) -w | tee rules"
        #rlRun "grep Unknown rules" 1
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semodule -r test_module"
        rlRun "rm test testfile test_module.pp test_module.mod rules"
    rlPhaseEnd
rlJournalEnd

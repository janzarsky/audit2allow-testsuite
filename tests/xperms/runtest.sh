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

    rlPhaseStartTest "Denied ioctl number"
        rlRun "echo '' >/var/log/audit/audit.log"

        # ioctl() will return Permission denied because this ioctl number
        # is not allowed
        rlRun "./test testfile 0x42" 1

        # audit message is generated with ioctlcmd field
        rlRun "ausearch -m avc | grep 'ioctlcmd=0x42'"

        rlRun "ausearch -m avc | audit2allow"

        # audit2allow will suggest this:
        #
        #   allow unconfined_t my_test_file_t:file ioctl;
        #
        # which is allowed in current policy but further restricted by
        # allowxperm rule.
        #
        # Correct solution should be this:
        #
        #   allowxperm unconfined_t my_test_file_t:file ioctl 0x42;
        #
        rlRun "ausearch -m avc | audit2allow | grep -C 999 allowxperms"
    rlPhaseEnd

    rlPhaseStartTest "Allowed ioctl number"
        rlRun "echo '' >/var/log/audit/audit.log"

        # ioctl() will not return Permission denied because this ioctl number
        # is allowed
        rlRun "./test testfile 0x8927" 0

        # there should be no audit message because 0x8927 is allowed
        rlRun "ausearch -m avc | grep 'ioctlcmd'" 1
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semodule -r test_module"
        rlRun "rm test testfile test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

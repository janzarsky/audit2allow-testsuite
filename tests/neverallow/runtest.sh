. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test_module.te" || rlDie

        # add module which contains neverallow rule:
        #
        #   neverallow unconfined_t my_test_file_t:file write;
        #
        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"

        rlRun "touch testfile"
        rlRun "chcon -t my_test_file_t testfile"

        rlRun "ls -lZ"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        # test reading
        rlRun "cat testfile"

        # test writing, it will fail and create an AVC message
        rlRun "echo asdf > testfile" 1

        # audit2allow will generate rule:
        #
        #   allow unconfined_t my_test_file_t:file write;
        #
        # which is in conflict with a neverallow rule. This module cannot be
        # loaded if with option 'expand-check = 1' in
        # /etc/selinux/semanage.conf
        rlRun "ausearch -m avc | audit2allow"

        # look for some warning about neverallow rules
        rlRun "ausearch -m avc | audit2allow | grep neverallow"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semodule -r test_module"
        rlRun "rm testfile test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

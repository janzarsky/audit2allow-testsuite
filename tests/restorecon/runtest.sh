. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test_module.te" || rlDie

        rlRun "which audit2allow"

        # load module which creates new type and allows reading by unconfined_t
        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"

        # create file which has other than default context
        rlRun "touch testfile"
        rlRun "chcon -t my_test_file_t testfile"

        rlRun "ls -lZ"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        # default context should be something different
        rlRun "matchpathcon testfile | grep my_test_file_t" 1

        # try reading from file
        rlRun "cat testfile" 1

        # try writing to file
        rlRun "echo asdf > testfile" 1

        # there should be an AVC message
        rlRun "ausearch -m all | grep -C 999 'denied  { write }'"

        # audit2allow will produce allow rule while it could also recommend
        # restorecon for the file
        rlRun "ausearch -m all | python $(which audit2allow)"

        # look for restorecon recommendation
        rlRun "ausearch -m all | python $(which audit2allow) | grep restorecon"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semodule -r test_module"
        rlRun "rm testfile test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

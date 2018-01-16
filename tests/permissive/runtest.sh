. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        rlAssertExists "test.c" || rlDie
        rlAssertExists "test_module.te" || rlDie

        # add module with new domain my_test_domain_t
        rlRun "checkmodule -m -M test_module.te -o test_module.mod"
        rlRun "semodule_package -m test_module.mod -o test_module.pp"
        rlRun "semodule -i test_module.pp"

        rlRun "touch testfile"

        # create simple program which opens file
        rlRun "gcc test.c -o test -lselinux"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "true >/var/log/audit/audit.log"

        # run test program with context 'my_test_domain_t' and try to open file
        rlRun "runcon -t my_test_domain_t ./test testfile > output" 1
        rlRun "cat output"

        # check that open failed
        rlRun "grep 'open(...) = -1' output"

        # there should be AVC message that open was denied
        rlRun "ausearch -m avc | grep 'denied  { open }'"
        rlRun "ausearch -m avc | audit2allow | grep 'allow my_test_domain_t admin_home_t:file open;'"

        rlRun "true >/var/log/audit/audit.log"

        # set my_test_domain_t as permissive
        rlRun "semanage permissive -a my_test_domain_t"

        # run program again, it should not fail
        rlRun "runcon -t my_test_domain_t ./test testfile > output"
        rlRun "cat output"

        rlRun "grep 'open(...) = -1' output" 1

        # but there should still be AVCs
        rlRun "ausearch -m avc | grep 'denied  { open }'"
        rlRun "ausearch -m avc | audit2allow | grep 'allow my_test_domain_t admin_home_t:file open;'"

        # audit2allow should warn that this domain is permissive
        rlRun "ausearch -m avc | audit2allow | grep permissive"
        rlRun "ausearch -m avc | audit2why | grep permissive"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "semanage permissive -d my_test_domain_t"
        rlRun "semodule -r test_module"
        rlRun "rm output test testfile test_module.pp test_module.mod"
    rlPhaseEnd
rlJournalEnd

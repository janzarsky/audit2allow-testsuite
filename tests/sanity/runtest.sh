. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup

    rlPhaseEnd

    rlPhaseStartTest
        test_avc='type=AVC msg=audit(1218128130.653:334): avc:  denied  { connectto } for  pid=9111 comm="smtpd" path="/var/spool/postfix/postgrey/socket" scontext=system_u:system_r:postfix_smtpd_t:s0 tcontext=system_u:system_r:initrc_t:s0 tclass=unix_stream_socket'
        test_result='allow postfix_smtpd_t initrc_t:unix_stream_socket connectto;'

        rlRun "echo '$test_avc' | audit2allow | grep '$test_result'"
    rlPhaseEnd

    rlPhaseStartCleanup

    rlPhaseEnd
rlJournalEnd

#rlJournalPrintText

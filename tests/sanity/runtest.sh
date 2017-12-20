. /usr/share/beakerlib/beakerlib.sh

function check_output {
    rlRun "echo '$1' | audit2allow | grep '$2'"
}

rlJournalStart
    rlPhaseStartSetup

    rlPhaseEnd

    rlPhaseStartTest
        check_output \
            'type=AVC msg=audit(1218128130.653:334): avc:  denied  { connectto } for scontext=system_u:system_r:postfix_smtpd_t:s0 tcontext=system_u:system_r:initrc_t:s0 tclass=unix_stream_socket' \
            'allow postfix_smtpd_t initrc_t:unix_stream_socket connectto;'

        check_output \
            'type=AVC msg=audit(1513764194.716:344): avc:  denied  { entrypoint } for scontext=system_u:system_r:kernel_t:s0-s0:c0.c1023 tcontext=unconfined_u:object_r:user_home_t:s0 tclass=file permissive=0' \
            'allow kernel_t user_home_t:file entrypoint;'
    rlPhaseEnd

    rlPhaseStartCleanup

    rlPhaseEnd
rlJournalEnd

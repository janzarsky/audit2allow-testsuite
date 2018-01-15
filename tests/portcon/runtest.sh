. /usr/share/beakerlib/beakerlib.sh

rlJournalStart
    rlPhaseStartSetup
        # we expect that there is pulseaudio module present which contains
        # following rules:
        #
        #   type pulseaudio_t;
        #   type pulseaudio_port_t;
        #   portcon tcp 4713 system_u:object_r:pulseaudio_port_t:s0
        #   portcon udp 4713 system_u:object_r:pulseaudio_port_t:s0
        #

        rlRun "true >/var/log/audit/audit.log"
    rlPhaseEnd

    rlPhaseStartTest
        # AVC: pulseaudio_t was denied name_bind on udp port 14 (which is
        # reserved_port_t)
        # TODO: generate real AVC
        avc='type=AVC msg=audit(1458086688.481:1296): avc: denied { name_bind } for src=14 scontext=system_u:system_r:pulseaudio_t:s0 tcontext=system_u:object_r:reserved_port_t:s0 tclass=udp_socket';

        rlRun "echo '$avc' | audit2allow"

        # audit2allow should not provide allow rule, pulseaudio_t would gain
        # access to all reserved ports
        rlRun "echo '$avc' | audit2allow | grep 'allow pulseaudio_t reserved_port_t:udp_socket name_bind;'" 1

        # audit2allow should provide semanage port command
        # 
        #   semanage port -a -t pulseaudio_port_t -p udp 14
        #
        rlRun "echo '$avc' | audit2allow | grep 'semanage port'"
    rlPhaseEnd

    rlPhaseStartCleanup
    rlPhaseEnd
rlJournalEnd

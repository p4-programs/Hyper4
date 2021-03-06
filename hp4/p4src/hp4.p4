/*
David Hancock
FLUX Research Group
University of Utah
dhancock@cs.utah.edu

HyPer4: A P4 Program to Run Other P4 Programs

hp4.p4: Define the ingress and egress pipelines, including multicast support.
*/

#include "includes/defines.p4"
#include "includes/headers.p4"
#include "includes/parser.p4"
#include "includes/deparse_prep.p4"
#include "includes/setup.p4"
#include "includes/stages.p4"
#include "includes/checksums.p4"
#include "includes/resize_pr.p4"
//#include "includes/debug.p4"

metadata meta_ctrl_t meta_ctrl;
metadata meta_primitive_state_t meta_primitive_state;
metadata extracted_t extracted;
metadata tmeta_t tmeta;
metadata csum_t csum;

metadata intrinsic_metadata_t intrinsic_metadata;

action a_mc_skip() {
  modify_field(standard_metadata.egress_spec, standard_metadata.egress_spec - 1);
  modify_field(meta_ctrl.multicast_current_egress, meta_ctrl.multicast_current_egress - 1);
}

table mc_skip {
  reads {
    standard_metadata.egress_spec : exact;
  }
  actions {
    a_mc_skip;
    a_drop;
  }
}

action a_set_dest_port(port) {
  modify_field(standard_metadata.egress_spec, standard_metadata.ingress_port);
  modify_field(meta_ctrl.virt_egress_port, port);
}

action a_physical_egress(port) {
  modify_field(standard_metadata.egress_spec, port);
}

table t_link {
  reads {
    meta_ctrl.program : exact;
    standard_metadata.egress_spec : exact;
  }
  actions {
    a_set_dest_port;
    a_physical_egress;
    _no_op;
    a_drop;
  }
}

control ingress {
  setup();

  if (meta_ctrl.stage == NORM) { //_condition_15
    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 1) { //_condition_16
      stage1();
    }
    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 2) {
      stage2();
    }
    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 3) {
      stage3();
    }
    if (meta_ctrl.next_table != DONE and meta_ctrl.next_stage == 4) {
      stage4();
    }
  }
  if (meta_ctrl.mc_flag == 1) {
    if (standard_metadata.egress_spec == standard_metadata.ingress_port) {
      apply(mc_skip);
    }
  }

  apply(t_link);
}

field_list clone_fl {
  standard_metadata;
  meta_ctrl;
  extracted;
}

action mod_and_clone(port) {
  modify_field(meta_ctrl.multicast_current_egress, port);
  clone_egress_pkt_to_egress(port, clone_fl);
}

table t_multicast {
  reads {
    meta_ctrl.program : exact;
    meta_ctrl.multicast_seq_id : exact;
    meta_ctrl.multicast_current_egress : exact;
    standard_metadata.ingress_port : ternary;
  }
  actions {
    mod_and_clone;
    _no_op;
  }
}

field_list fl_virt_net {
  meta_ctrl.program;
  meta_ctrl.virt_egress_port;
  standard_metadata;
}

action a_virt_net(next_prog) {
  modify_field(meta_ctrl.program, next_prog);
  recirculate(fl_virt_net);
}

table t_virt_net {
  reads {
    meta_ctrl.program : exact;
    meta_ctrl.virt_egress_port : exact;
  }
  actions {
    _no_op;
    a_virt_net;
  }
}

control egress {
  if(meta_ctrl.mc_flag == 1) {
    apply(t_multicast);
  }
  apply(csum16);
  apply(t_resize_pr);
  apply(t_prep_deparse_SEB);
  if(parse_ctrl.numbytes > 20) { // 341
    apply(t_prep_deparse_20_39);
    if(parse_ctrl.numbytes > 40) { // 342
      apply(t_prep_deparse_40_59);
      if(parse_ctrl.numbytes > 60) { // 343
        apply(t_prep_deparse_60_79);
        if(parse_ctrl.numbytes > 80) { // 344
          apply(t_prep_deparse_80_99);
        }
      }
    }
  }
  if(meta_ctrl.virt_egress_port > 0) {
    apply(t_virt_net);
  }
}

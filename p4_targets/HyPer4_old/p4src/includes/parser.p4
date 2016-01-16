/*
David Hancock
University of Utah
dhancock@cs.utah.edu

HyPer4 - A P4 hypervisor extending live reconfigurability and other features
         to all P4 targets with sufficient resources
*/

header bitfield_256_t bitfield_256;
header bitfield_512_t bitfield_512;
header bitfield_768_t bitfield_768;

register parse_width {
  width : 16;
  instance_count : 1;
}

register first_table {
  width: 8;
  instance_count : 1;
}

register r_next_action {
  width : 8;
  instance_count : 20;
}

// first param of each primitive action (pa)
register r_pa_params_1 {
  width : 8;
  instance_count : 20;
}

// second param of each pa
register r_pa_params_2 {
  width : 8;
  instance_count : 20;
}

// third param of each pa
register r_pa_params_3 {
  width : 8;
  instance_count : 20;
}

// fourth param of each pa
register r_pa_params_4 {
  width : 8;
  instance_count : 20;
}

// for storing the target's custom metadata
register target_meta {
  width : 8;
  instance_count : 100;
}

metadata local_metadata_t local_meta;

parser start {
  return select(local_meta.parse_width) {
    256 : parse_256;
    512 : parse_512;
    768 : parse_768;
    default : main;
  }
}

parser parse_256 {
  extract(bitfield_256);
  return main;
}

parser parse_512 {
  extract(bitfield_512);
  return main;
}

parser parse_768 {
  extract(bitfield_768);
  return main;
}
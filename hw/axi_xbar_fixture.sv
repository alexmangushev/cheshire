`include "axi/typedef.svh"
`include "cheshire/typedef.svh"

package axi_xbar_fixture_pkg;
  import cheshire_pkg::*;
  import tb_cheshire_pkg::*;

  localparam cheshire_cfg_t Cfg = TbCheshireConfigs[3];

  `CHESHIRE_TYPEDEF_ALL(, Cfg)

  localparam axi_in_t   AxiIn   = gen_axi_in(Cfg);
  localparam axi_out_t  AxiOut  = gen_axi_out(Cfg);

  // Define needed parameters
  localparam int unsigned AxiStrbWidth  = Cfg.AxiDataWidth / 8;
  localparam int unsigned AxiSlvIdWidth = Cfg.AxiMstIdWidth + $clog2(AxiIn.num_in);

  // Type for address map entries
  typedef struct packed {
    logic [$bits(aw_bt)-1:0] idx;
    addr_t start_addr;
    addr_t end_addr;
  } addr_rule_t;

  // Generate address map
  function automatic addr_rule_t [AxiOut.num_rules-1:0] gen_axi_map();
    addr_rule_t [AxiOut.num_rules-1:0] ret;
    for (int i = 0; i < AxiOut.num_rules; ++i)
      ret[i] = '{idx: AxiOut.map[i].idx,
          start_addr: AxiOut.map[i].start, end_addr: AxiOut.map[i].pte};
    return ret;
  endfunction

  localparam addr_rule_t [AxiOut.num_rules-1:0] AxiMap = gen_axi_map();

  // Connectivity of Xbar
  axi_mst_req_t [AxiIn.num_in-1:0]    axi_in_req, axi_rt_in_req;
  axi_mst_rsp_t [AxiIn.num_in-1:0]    axi_in_rsp, axi_rt_in_rsp;
  axi_slv_req_t [AxiOut.num_out-1:0]  axi_out_req;
  axi_slv_rsp_t [AxiOut.num_out-1:0]  axi_out_rsp;

endpackage

module axi_xbar_fixture
import axi_xbar_fixture_pkg::*;
import cf_math_pkg::idx_width;
#(
  parameter bit Clearable = 1'b0,
  parameter int unsigned NumSlvPorts = 32'd4
) (
  input logic clk_i,
  input logic rst_ni,
  input logic test_i,
  input logic clr_i,
  output logic clr_ack_o,
  input  axi_mst_req_t [NumSlvPorts-1:0] slv_ports_req_i,
  output axi_mst_rsp_t [NumSlvPorts-1:0] slv_ports_resp_o,
  output axi_slv_req_t [AxiOut.num_out-1:0] mst_ports_req_o,
  input  axi_slv_rsp_t [AxiOut.num_out-1:0] mst_ports_resp_i,
  input  logic      [NumSlvPorts-1:0]                                en_default_mst_port_i,
  input  logic      [NumSlvPorts-1:0][idx_width(AxiOut.num_out)-1:0] default_mst_port_i
);

  // Configure AXI Xbar
  localparam axi_pkg::xbar_cfg_t AxiXbarCfg = '{
    NoSlvPorts:         NumSlvPorts,
    NoMstPorts:         AxiOut.num_out,
    MaxMstTrans:        Cfg.AxiMaxMstTrans,
    MaxSlvTrans:        Cfg.AxiMaxSlvTrans,
    FallThrough:        0,
    LatencyMode:        axi_pkg::CUT_ALL_PORTS,
    PipelineStages:     0,
    AxiIdWidthSlvPorts: Cfg.AxiMstIdWidth,
    AxiIdUsedSlvPorts:  Cfg.AxiMstIdWidth,
    UniqueIds:          0,
    AxiAddrWidth:       Cfg.AddrWidth,
    AxiDataWidth:       Cfg.AxiDataWidth,
    NoAddrRules:        AxiOut.num_rules
  };

  if (Clearable) begin : gen_clearable

    axi_xbar_clearable #(
      .Cfg            ( AxiXbarCfg ),
      .ATOPs          ( 1  ),
      .Connectivity   ( '1 ),
      .slv_aw_chan_t  ( axi_mst_aw_chan_t ),
      .mst_aw_chan_t  ( axi_slv_aw_chan_t ),
      .w_chan_t       ( axi_mst_w_chan_t  ),
      .slv_b_chan_t   ( axi_mst_b_chan_t  ),
      .mst_b_chan_t   ( axi_slv_b_chan_t  ),
      .slv_ar_chan_t  ( axi_mst_ar_chan_t ),
      .mst_ar_chan_t  ( axi_slv_ar_chan_t ),
      .slv_r_chan_t   ( axi_mst_r_chan_t  ),
      .mst_r_chan_t   ( axi_slv_r_chan_t  ),
      .slv_req_t      ( axi_mst_req_t ),
      .slv_resp_t     ( axi_mst_rsp_t ),
      .mst_req_t      ( axi_slv_req_t ),
      .mst_resp_t     ( axi_slv_rsp_t ),
      .rule_t         ( addr_rule_t ),
      .NumPending     ( 32'd24 )
    ) i_axi_xbar (
      .clk_i,
      .rst_ni,
      .test_i,
      .clr_i,
      .clr_ack_o,
      .slv_ports_req_i,
      .slv_ports_resp_o,
      .mst_ports_req_o,
      .mst_ports_resp_i,
      .addr_map_i             ( AxiMap ),
      .en_default_mst_port_i,
      .default_mst_port_i
    );

  end else begin : gen_nonclearable // block: gen_clearable

    axi_xbar #(
      .Cfg            ( AxiXbarCfg ),
      .ATOPs          ( 1  ),
      .Connectivity   ( '1 ),
      .slv_aw_chan_t  ( axi_mst_aw_chan_t ),
      .mst_aw_chan_t  ( axi_slv_aw_chan_t ),
      .w_chan_t       ( axi_mst_w_chan_t  ),
      .slv_b_chan_t   ( axi_mst_b_chan_t  ),
      .mst_b_chan_t   ( axi_slv_b_chan_t  ),
      .slv_ar_chan_t  ( axi_mst_ar_chan_t ),
      .mst_ar_chan_t  ( axi_slv_ar_chan_t ),
      .slv_r_chan_t   ( axi_mst_r_chan_t  ),
      .mst_r_chan_t   ( axi_slv_r_chan_t  ),
      .slv_req_t      ( axi_mst_req_t ),
      .slv_resp_t     ( axi_mst_rsp_t ),
      .mst_req_t      ( axi_slv_req_t ),
      .mst_resp_t     ( axi_slv_rsp_t ),
      .rule_t         ( addr_rule_t )
    ) i_axi_xbar (
      .clk_i,
      .rst_ni,
      .test_i,
      .slv_ports_req_i,
      .slv_ports_resp_o,
      .mst_ports_req_o,
      .mst_ports_resp_i,
      .addr_map_i             ( AxiMap ),
      .en_default_mst_port_i,
      .default_mst_port_i
    );

    assign clr_ack_o = 1'b1;

  end // block: gen_nonclearable

endmodule

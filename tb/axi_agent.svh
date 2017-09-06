class axi_agent extends uvm_agent;
  `uvm_component_utils(axi_agent)
  
  uvm_analysis_port #(axi_seq_item) ap;
  
  
  axi_agent_config    m_config;
  axi_driver          m_driver;
  axi_monitor         m_monitor;
  axi_sequencer       m_seqr;
  axi_coveragecollector m_coveragecollector;
  
  
  extern function new (string name="axi_agent", uvm_component parent=null);
  extern function void build_phase              (uvm_phase phase);
  extern function void connect_phase            (uvm_phase phase);
      
endclass : axi_agent
     
function axi_agent::new (string name="axi_agent", uvm_component parent=null);
  super.new(name, parent);
endfunction : new
    
function void axi_agent::build_phase(uvm_phase phase);
  super.build_phase(phase);
  
  if (m_config == null) begin
    if (!uvm_config_db #(axi_agent_config)::get(this, "", "m_config", m_config)) begin
      `uvm_info(this.get_type_name, "Unable to fetch axi_agent_config from config db. Using defaults", UVM_INFO)
    end 
    // Create config object. 
    m_config = axi_agent_config::type_id::create("m_config", this);
    
  end
  
  ap = new("ap", this);
  
  if (m_config.m_active == UVM_ACTIVE) begin
     m_driver  = axi_driver::type_id::create("m_driver",  this);
     m_seqr    = axi_sequencer::type_id::create("m_seqr", this);

     m_driver.m_config = m_config;
  end

  m_monitor = axi_monitor::type_id::create("m_monitor", this);

  
  m_coveragecollector = axi_coveragecollector::type_id::create("m_coveragecollector", this);

//  m_monitor.m_config = m_config;
  
endfunction : build_phase
    
function void axi_agent::connect_phase (uvm_phase phase);
  super.connect_phase(phase);
  
  if (m_config.m_active == UVM_ACTIVE) begin
   m_driver.seq_item_port.connect(m_seqr.seq_item_export);
  end
  
  m_monitor.ap.connect(m_coveragecollector.analysis_export);
  m_monitor.ap.connect(ap);

endfunction : connect_phase
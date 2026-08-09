   #  | Issue | Location | Suggested Fix
  ----|-----------------------------------|--------------------------|-----------------------------------------------------
   B1 | Synchronous DB writes in hot path | orchestrator.ex:890, 425 | Wrap StepMetrics.record_metric in Task.start        
      |                                   |                          | or use a GenServer/Agent collector that batches     
      |                                   |                          | writes. At minimum, use Task.Supervisor.start_child   
      |                                   |                          | with a dedicated supervisor.                        
   B2 | toggle_debug_panel latch bug —    | blah.ex:100              | Change to assign(:debug_log_enabled?, new_panel) or 
      | debug_log_enabled? never resets   |                          | introduce a separate debug_panel_ever_opened? flag. 
      | to false after first open         |                          |                                                     
   B3 | Mix.env() compile-time divergence | preferences_editor.ex:12 | Centralise in config: config :api_services,         
      |                                   |                          | :amc_default_show_debug_log set per env. Read via   
      |                                   |                          | Application.get_env/3 at runtime.                   
   B4 | progress_reassurance/4 can crash  | amc_query_agent.ex:5335  | Add a guard when is_map(stats) and a fallback that  
      | on nil stats                      |                          | constructs default stats.                            
   B5 | Flag rename leaves orphaned       | registry.ex              | Add a data migration or fallback                    

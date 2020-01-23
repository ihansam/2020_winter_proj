/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                         */
/*  \   \        Copyright (c) 2003-2013 Xilinx, Inc.                 */
/*  /   /        All Right Reserved.                                  */
/* /---/   /\                                                         */
/* \   \  /  \                                                        */
/*  \___\/\___\                                                       */
/**********************************************************************/


#include "iki.h"
#include <string.h>
#include <math.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
typedef void (*funcp)(char *, char *);
extern int main(int, char**);
extern void execute_2(char*, char *);
extern void execute_136(char*, char *);
extern void execute_137(char*, char *);
extern void execute_198(char*, char *);
extern void execute_199(char*, char *);
extern void execute_204(char*, char *);
extern void execute_205(char*, char *);
extern void execute_206(char*, char *);
extern void execute_207(char*, char *);
extern void vlog_simple_process_execute_1_fast_no_reg_no_agg(char*, char*, char*);
extern void execute_1046(char*, char *);
extern void execute_1047(char*, char *);
extern void execute_1048(char*, char *);
extern void execute_1049(char*, char *);
extern void execute_1050(char*, char *);
extern void execute_1051(char*, char *);
extern void execute_1052(char*, char *);
extern void execute_1053(char*, char *);
extern void execute_1054(char*, char *);
extern void execute_1055(char*, char *);
extern void execute_1056(char*, char *);
extern void execute_1057(char*, char *);
extern void execute_1058(char*, char *);
extern void execute_1059(char*, char *);
extern void execute_1060(char*, char *);
extern void execute_208(char*, char *);
extern void execute_209(char*, char *);
extern void execute_242(char*, char *);
extern void execute_291(char*, char *);
extern void execute_292(char*, char *);
extern void execute_210(char*, char *);
extern void execute_211(char*, char *);
extern void execute_212(char*, char *);
extern void execute_213(char*, char *);
extern void execute_243(char*, char *);
extern void execute_244(char*, char *);
extern void execute_245(char*, char *);
extern void execute_246(char*, char *);
extern void execute_247(char*, char *);
extern void execute_248(char*, char *);
extern void execute_249(char*, char *);
extern void execute_250(char*, char *);
extern void execute_548(char*, char *);
extern void execute_549(char*, char *);
extern void execute_552(char*, char *);
extern void execute_674(char*, char *);
extern void execute_675(char*, char *);
extern void execute_676(char*, char *);
extern void execute_758(char*, char *);
extern void execute_759(char*, char *);
extern void execute_201(char*, char *);
extern void execute_202(char*, char *);
extern void execute_203(char*, char *);
extern void execute_1061(char*, char *);
extern void execute_1062(char*, char *);
extern void execute_1063(char*, char *);
extern void execute_1064(char*, char *);
extern void execute_1065(char*, char *);
extern void vlog_transfunc_eventcallback(char*, char*, unsigned, unsigned, unsigned, char *);
funcp funcTab[59] = {(funcp)execute_2, (funcp)execute_136, (funcp)execute_137, (funcp)execute_198, (funcp)execute_199, (funcp)execute_204, (funcp)execute_205, (funcp)execute_206, (funcp)execute_207, (funcp)vlog_simple_process_execute_1_fast_no_reg_no_agg, (funcp)execute_1046, (funcp)execute_1047, (funcp)execute_1048, (funcp)execute_1049, (funcp)execute_1050, (funcp)execute_1051, (funcp)execute_1052, (funcp)execute_1053, (funcp)execute_1054, (funcp)execute_1055, (funcp)execute_1056, (funcp)execute_1057, (funcp)execute_1058, (funcp)execute_1059, (funcp)execute_1060, (funcp)execute_208, (funcp)execute_209, (funcp)execute_242, (funcp)execute_291, (funcp)execute_292, (funcp)execute_210, (funcp)execute_211, (funcp)execute_212, (funcp)execute_213, (funcp)execute_243, (funcp)execute_244, (funcp)execute_245, (funcp)execute_246, (funcp)execute_247, (funcp)execute_248, (funcp)execute_249, (funcp)execute_250, (funcp)execute_548, (funcp)execute_549, (funcp)execute_552, (funcp)execute_674, (funcp)execute_675, (funcp)execute_676, (funcp)execute_758, (funcp)execute_759, (funcp)execute_201, (funcp)execute_202, (funcp)execute_203, (funcp)execute_1061, (funcp)execute_1062, (funcp)execute_1063, (funcp)execute_1064, (funcp)execute_1065, (funcp)vlog_transfunc_eventcallback};
const int NumRelocateId= 59;

void relocate(char *dp)
{
	iki_relocate(dp, "xsim.dir/MAC_Unit_behav/xsim.reloc",  (void **)funcTab, 59);

	/*Populate the transaction function pointer field in the whole net structure */
}

void sensitize(char *dp)
{
	iki_sensitize(dp, "xsim.dir/MAC_Unit_behav/xsim.reloc");
}

	// Initialize Verilog nets in mixed simulation, for the cases when the value at time 0 should be propagated from the mixed language Vhdl net

void wrapper_func_0(char *dp)

{

}

void simulate(char *dp)
{
		iki_schedule_processes_at_time_zero(dp, "xsim.dir/MAC_Unit_behav/xsim.reloc");
	wrapper_func_0(dp);

	iki_execute_processes();

	// Schedule resolution functions for the multiply driven Verilog nets that have strength
	// Schedule transaction functions for the singly driven Verilog nets that have strength

}
#include "iki_bridge.h"
void relocate(char *);

void sensitize(char *);

void simulate(char *);

extern SYSTEMCLIB_IMP_DLLSPEC void local_register_implicit_channel(int, char*);
extern void implicit_HDL_SCinstatiate();

extern SYSTEMCLIB_IMP_DLLSPEC int xsim_argc_copy ;
extern SYSTEMCLIB_IMP_DLLSPEC char** xsim_argv_copy ;

int main(int argc, char **argv)
{
    iki_heap_initialize("ms", "isimmm", 0, 2147483648) ;
    iki_set_sv_type_file_path_name("xsim.dir/MAC_Unit_behav/xsim.svtype");
    iki_set_crvs_dump_file_path_name("xsim.dir/MAC_Unit_behav/xsim.crvsdump");
    void* design_handle = iki_create_design("xsim.dir/MAC_Unit_behav/xsim.mem", (void *)relocate, (void *)sensitize, (void *)simulate, 0, isimBridge_getWdbWriter(), 0, argc, argv);
     iki_set_rc_trial_count(100);
    (void) design_handle;
    return iki_simulate_design();
}

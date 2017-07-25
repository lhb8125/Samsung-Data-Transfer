#fc  	=  tau_f90.sh
fc  	=  mpif90
exe		=  mbt

#flag	=  -O0 -Wall -Wextra -Wline-truncation -Wcharacter-truncation \
		   -Wsurprising -Waliasing -Wunused-parameter -Wconversion\
		   -fwhole-file -fcheck=all -fbacktrace -fPIC
#flag	=  -O2 -march=native -fwhole-file -fPIC

#flag	=  -O0 -module mod -check all -warn all -warn unused -fpe3 -traceback \
		   -gen-interface -check noarg_temp_created -fpic
#flag	=  -O2 -axSSE4.2 -module mod -fpic -vec-report0

##for pgfortran
flag    =  -O0 -module mod -Mcuda=charstring -Kieee -llapack
#flag    =   -module mod -Kieee

##for gfort
#flag    =  -g -J mod -fPIC

libdir	=  -L/forall/ParMetis-3.2.0 -lparmetis -lmetis -L/usr/local/lib/ -lcgns 
incdir	=  -I/usr/local/include -I/forall/ParMetis-3.2.0
inc		=  ./include/var_def.cuf
#inc_cuda=  ./include/cuda_var_def.cuf
#inc_mesh=  ./include/var_mesh.f90
inc_mesh=  ./include/var_mesh.cuf

main	=  main.o setup.o parallel.o sfci.o sfcs.o sfcd.o linear_solver.o
mesh	=  mesh.o load_balance.o mesh_io.o bnd.o
fr		=  fr_mesh.o fr_rhs.o fr_rhs_vis.o fr_line.o fr_quad.o fr_mortar.o \
		   fr_bnd.o fr_slv.o fr_slv_exp.o fr_wr.o fr_uns.o
fv		=  fv_mesh.o gpu_fv_slv.o gpu_fv_bnd.o gpu_fv_slv_exp.o gpu_slv.o \
		   gpu_fv_rhs.o fv_bnd.o fv_slv_exp.o fv_uns.o fv_rhs.o fv_slv.o \
		   slv.o fv_gpu.o temp.o ausm.o
heat	=  heat_mesh.o heat_rhs.o heat_slv.o
blas	=  blas.o

#cuda_var_def = cuda_var_def.o
#cuda_fv     = cuda_fv_rhs.o cuda_fv_slv.o 
#cuda_slv    = cuda_slv.o

object	=   $(main) $(mesh) $(blas) $(fv) 


edit:		dir_mod $(object)
			$(fc) $(flag)   -o $(exe) $(object) $(libdir) $(incdir)

dir_mod:
			mkdir -p mod

#var_mesh.o:		$(inc_mesh)
#			$(fc) $(flag)  -c $< -o $@ $(libdir) $(incdir)

#cuda_var_def.o:		$(inc)
#			$(fc) $(flag)  -c $< -o $@ $(libdir) $(incdir)

#$(cuda_slv):		%.o: %.cuf $(inc) 
#			$(fc) $(flag)  -c $< -o $@ $(libdir) $(incdir)


$(main):	%.o: %.cuf $(inc) 
			$(fc) $(flag) -c $< -o $@ $(libdir) $(incdir)


$(mesh):	%.o: %.cuf $(inc_mesh)
			$(fc) $(flag) -c $< -o $@ $(libdir) $(incdir)
$(blas):
			$(fc) $(flag) -c blas.f -o blas.o

$(fv):		%.o: %.cuf
			$(fc) $(flag) -c $< -o $@ $(libdir) $(incdir)

clean:
			rm -f $(exe) *.o *.a *.so mod/*.* *.mod profile.*

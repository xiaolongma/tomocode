include ../../Makerules
OBJ=matr.o 
OBJ+=../../SUBR/3D_MODEL/anom_3d_xyz_lin_v.o ../../SUBR/CONVERS/decsf.o ../../SUBR/CONVERS/epic_dist.o  ../../SUBR/1D_TRACING/halftrace.o  ../../SUBR/1D_TRACING/prepare_ref.o ../../SUBR/1D_TRACING/ray_lay.o ../../SUBR/3D_MODEL/read_3d_mod_v.o ../../SUBR/RAYS_LOCATE/read_z_limit.o ../../SUBR/1D_TRACING/ref_time.o ../../SUBR/CONVERS/sfdec.o ../../SUBR/BENDING_TELE/trace_1D.o ../../SUBR/3D_MODEL/velocity.o ../../SUBR/SYNTH/vert_anom.o ../../SUBR/1D_TRACING/vrefmod.o ../../SUBR/RAYS_LOCATE/z_lim.o
BIN=matr.exe

%.o:%.f90
	$(FC) -c $(FFLAGS) $<

all: compile

compile: $(OBJ)
	$(FC)  $(FFLAGS) -o $(BIN) $(OBJ) $(LIBS) 

clean:
	@rm -f *.o $(BIN)

fullclean: clean
	@rm $(BIN)

install:
	@cp $(BIN) $(DESTDIR)


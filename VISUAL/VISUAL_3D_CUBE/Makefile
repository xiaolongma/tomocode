include ../../Makerules
OBJ=visual_3d_cube.o 
OBJ+=../../SUBR/CONVERS/decsf.o ../../SUBR/CONVERS/sfdec.o ../../SUBR/VISUAL/dv_1_gr_xyz_v.f90 ../../SUBR/INVERS/kram3.f90 ../../SUBR/VISUAL/prepare_model_v.f90 ../../SUBR/1D_TRACING/vrefmod.f90 ../../SUBR/SYNTH/read_ini_model.o ../../SUBR/SYNTH/read_ini_model_3d.o ../../SUBR/SYNTH/ini_3d_model.o
BIN=visual_3d_cube.exe

%.o:%.f90
	$(FC) -c $(FFLAGS) $<

all: compile

compile: $(OBJ)
	$(FC)  $(FFLAGS) -o $(BIN) $(OBJ) $(LIBS) 

clean:
	@rm -f *.o $(BIN)

fullclean: clean
	@rm -f $(BIN)

install:
	@cp $(BIN) $(DESTDIR)


character*8 ar,re,line
character*1 ps,it 
integer nrps(2)

allocatable dvan(:,:),vvv(:,:),vtmp(:,:),dv_3d(:,:,:)

common/pi/pi,per
common/center/fi0,tet0
common/refmod/nrefmod,hmod(600),vmodp(600),vmods(600)

w_limit=0.2

one=1.e0
pi=asin(one)*2.e0
per=pi/180.e0
rz=6371.



open(1,file='../../model.dat')
read(1,'(a8)')re
read(1,'(a8)')ar
read(1,*)iter		! code of the grid
close(1)
write(it,'(i1)')iter

write(*,*)' region : ',re,' AREA : ',ar,' iter=',iter


!******************************************************************
open(1,file='../../DATA/'//re//'/'//ar//'/INI_PARAM/major_param.dat')
do i=1,10000
	read(1,'(a8)',end=563)line
	if(line.eq.'3D_MODEL') goto 564
end do
563 continue
write(*,*)' cannot find 3D_MODEL in major_param.dat!!!'
pause
564 continue
read(1,*) xx1,xx2,dxx 
read(1,*) yy1,yy2,dyy 
read(1,*) zz1,zz2,dzz  
read(1,*) smaxx
read(1,*) ismth
close(1)
!******************************************************************
open(1,file='../../DATA/'//re//'/'//ar//'/INI_PARAM/major_param.dat')
do i=1,10000
	read(1,'(a8)',end=573)line
	if(line.eq.'ORIENTAT') goto 574
end do
573 continue
write(*,*)' cannot find ORIENTATIONS in major_param.dat!!!'
pause
574 read(1,*)nornt
close(1)
!******************************************************************

rsmth=ismth+0.5
nxx=(xx2-xx1)/dxx+1
nyy=(yy2-yy1)/dyy+1
nzz=(zz2-zz1)/dzz+1
write(*,*)' nxx=',nxx,' nyy=',nyy,' nzz=',nzz


! Read the values of the reference model
open(1,file='../../DATA/'//re//'/'//ar//'/INI_PARAM/refmod.dat')
read(1,*,end=81)vpvs
i=0
82	i=i+1
	read(1,*,end=81)hmod(i),vmodp(i),vs
	if(vpvs.lt.0.000001) then
		vmods(i)=vs
	else
		vmods(i)=vmodp(i)/vpvs
	end if
	!write(*,*)hmod(i),vmodp(i),vmods(i)
goto 82
81	close(1)
nrefmod=i-1
write(*,*)' nrefmod=',nrefmod

allocate(dvan(nxx,nyy),vvv(nxx,nyy),vtmp(nxx,nyy),dv_3d(nxx,nyy,nzz))

open(1,file='../../DATA/'//re//'/'//ar//'/TIMES/numray1.dat')
read(1,*) nrps(1),nrps(2)
close(1)



do ips=1,2
	write(ps,'(i1)')ips
	if(nrps(ips).eq.0) then
		open(11,file='../../DATA/'//re//'/'//ar//'/3D_MODEL/dv_v'//ps//it//'.dat',form='binary')
		write(11)0,0,0
		write(11)0,0,0
		write(11)0,0,0
		close(11)
		cycle
	end if
	dv_3d=0

	do izz=1,nzz
		zzz=(izz-1)*dzz+zz1
		v0 = vrefmod(zzz,ips)
		if(mod(izz,5).eq.0) write(*,*)' izz=',izz,' zzz=',zzz
		vvv=0
		dvan=0
		do igr=1,nornt
			call prepare_model_v(re,ar,ips,iter,igr)
			vvv=0
			dvan=0
			DO iyy=1,nyy
			!DO iyy=76,76
				yyy=(iyy-1)*dyy+yy1
				do ixx=1,nxx
				!do ixx=76,76
					xxx=(ixx-1)*dxx+xx1
					!xxx=30
					dv=0
					www=0
					!write(*,*)xxx,yyy,zzz
					call dv_1_gr_xyz_v(xxx,yyy,zzz,smaxx, dv,www)
					!write(*,*)igr,' dv=',dv,' www=',www
					dvan(ixx,iyy)=dvan(ixx,iyy)+dv*www
					vvv(ixx,iyy)=vvv(ixx,iyy)+www
				end do
			end do
		end do

		!write(*,*)izz,' 1: dvan(76,76)=',dvan(76,76),vvv(76,76)

		!write(*,*)' mark1'

! Absolute values of anomalies:
		do iyy=1,nyy
			yyy=(iyy-1)*dyy+yy1
			do ixx=1,nxx
				vanm=0.
				if (vvv(ixx,iyy).gt.w_limit) then
					vanm=dvan(ixx,iyy)/vvv(ixx,iyy)
					!vanm=0.01 * van_pr * v0
				end if
				vtmp(ixx,iyy)=vanm
			end do
		end do
		dvan=vtmp
	!write(*,*)ilev,' 2: dvan(86,10)=',dvan(86,10)
		!write(*,*)' mark2'

! Smoothing:
		do ixx=1,nxx
			do iyy=1,nyy
				if(vvv(ixx,iyy).lt.w_limit) cycle
				vanm=0.
				iv=0
				do ix2=-ismth,ismth
					if (ixx+ix2.lt.1) cycle
					if (ixx+ix2.gt.nxx) cycle
					do iy2=-ismth,ismth
						if (iyy+iy2.lt.1) cycle
						if (iyy+iy2.gt.nyy) cycle
						if(vvv(ixx+ix2,iyy+iy2).lt.w_limit) cycle
						rr=ix2*ix2+iy2*iy2
						r=sqrt(rr)
						if(r.gt.rsmth) cycle
						iv=iv+1
						vanm=vanm+dvan(ixx+ix2,iyy+iy2)
					end do
				end do
				vtmp(ixx,iyy)=vanm/iv
			end do
		end do
		dvan=vtmp
	!write(*,*)ilev,' 3: dvan(86,10)=',dvan(86,10)
		!write(*,*)' izz=',izz,' nzz=',nzz

		do ixx=1,nxx
			do iyy=1,nyy
				dv_3D(ixx,iyy,izz)=dvan(ixx,iyy)
			end do
		end do


	end do		! izz=1,nzz


	open(11,file='../../DATA/'//re//'/'//ar//'/3D_MODEL/dv_v'//ps//it//'.dat',form='binary')
	write(11)xx1,nxx,dxx
	write(11)yy1,nyy,dyy
	write(11)zz1,nzz,dzz
	write(*,*)' nx=',nxx,' ny=',nyy,' nz=',nzz
	do izz=1,nzz
		write(11)((dv_3D(ixx,iyy,izz),ixx=1,nxx),iyy=1,nyy)
	end do
	close(11)
	!write(*,*)' dv_3D(86,25,10)=',dv_3D(86,25,10)

        ! BIANCHI -- writiing data for the opendtect.
	!open(11,file='../../DATA/'//re//'/'//ar//'/3D_MODEL/dv_v'//ps//it//'OD.dat',form='binary')
        !do iyy=1,nyy
        ! do ixx=1,nxx
   	!   do izz=1,nzz
	!	write(11) dv_3D(ixx,iyy,izz)
  	!   end do
	! end do
	!end do
	!close(11)

end do


stop
end

!        generated by tapenade     (inria, tropics team)
!  tapenade 3.10 (r5363) -  9 sep 2014 09:53
!
module zipperintegrations_b
  implicit none

contains
!  differentiation of flowintegrationzipper in reverse (adjoint) mode (with options i4 dr8 r8 noisize):
!   gradient     of useful results: pointref timeref tref rgas
!                pref rhoref funcvalues vars localvalues
!   with respect to varying inputs: pointref timeref tref rgas
!                pref rhoref funcvalues vars localvalues
!   rw status of diff variables: pointref:incr timeref:incr tref:incr
!                rgas:incr pref:incr rhoref:incr funcvalues:incr
!                vars:incr localvalues:in-out
  subroutine flowintegrationzipper_b(isinflow, conn, fams, vars, varsd, &
&   localvalues, localvaluesd, famlist, sps, withgathered, funcvalues, &
&   funcvaluesd)
! integrate over the trianges for the inflow/outflow conditions. 
    use constants
    use blockpointers, only : bctype
    use sorting, only : faminlist
    use flowvarrefstate, only : pref, prefd, pinf, pinfd, rhoref, &
&   rhorefd, pref, prefd, timeref, timerefd, lref, tref, trefd, rgas, &
&   rgasd, uref, urefd, uinf, uinfd
    use inputphysics, only : pointref, pointrefd, flowtype
    use flowutils_b, only : computeptot, computeptot_b, computettot, &
&   computettot_b
    use surfacefamilies, only : familyexchange, bcfamexchange
    use utils_b, only : mynorm2, mynorm2_b, cross_prod, cross_prod_b
    implicit none
! input/output variables
    logical, intent(in) :: isinflow
    integer(kind=inttype), dimension(:, :), intent(in) :: conn
    integer(kind=inttype), dimension(:), intent(in) :: fams
    real(kind=realtype), dimension(:, :), intent(in) :: vars
    real(kind=realtype), dimension(:, :) :: varsd
    real(kind=realtype), dimension(nlocalvalues), intent(inout) :: &
&   localvalues
    real(kind=realtype), dimension(nlocalvalues), intent(inout) :: &
&   localvaluesd
    integer(kind=inttype), dimension(:), intent(in) :: famlist
    integer(kind=inttype), intent(in) :: sps
    logical, intent(in) :: withgathered
    real(kind=realtype), dimension(:), optional, intent(in) :: &
&   funcvalues
    real(kind=realtype), dimension(:), optional :: funcvaluesd
! working variables
    integer(kind=inttype) :: i, j
    real(kind=realtype) :: sf, vmag, vnm, vxm, vym, vzm, fx, fy, fz
    real(kind=realtype) :: sfd, vmagd, vnmd, vxmd, vymd, vzmd, fxd, fyd&
&   , fzd
    real(kind=realtype), dimension(3) :: fp, mp, fmom, mmom, refpoint, &
&   ss, x1, x2, x3, norm
    real(kind=realtype), dimension(3) :: fpd, mpd, fmomd, mmomd, &
&   refpointd, ssd, x1d, x2d, x3d, normd
    real(kind=realtype) :: pm, ptot, ttot, rhom, gammam, mnm, &
&   massflowratelocal
    real(kind=realtype) :: pmd, ptotd, ttotd, rhomd, gammamd, mnmd, &
&   massflowratelocald
    real(kind=realtype) :: massflowrate, mass_ptot, mass_ttot, mass_ps, &
&   mass_mn
    real(kind=realtype) :: massflowrated, mass_ptotd, mass_ttotd, &
&   mass_psd, mass_mnd
    real(kind=realtype) :: mredim, pk, sigma_mn, sigma_ptot
    real(kind=realtype) :: mredimd, pkd, sigma_mnd, sigma_ptotd
    real(kind=realtype) :: internalflowfact, inflowfact, xc, yc, zc, &
&   cellarea, mx, my, mz
    real(kind=realtype) :: xcd, ycd, zcd, mxd, myd, mzd
    intrinsic sqrt
    intrinsic size
    real(kind=realtype), dimension(3) :: arg1
    real(kind=realtype), dimension(3) :: arg1d
    real(kind=realtype), dimension(3) :: arg2
    real(kind=realtype), dimension(3) :: arg2d
    real(kind=realtype) :: result1
    real(kind=realtype) :: result1d
    logical :: res
    real(kind=realtype) :: temp3
    real(kind=realtype) :: temp2
    real(kind=realtype) :: temp1
    real(kind=realtype) :: temp0
    real(kind=realtype) :: tempd9
    real(kind=realtype) :: tempd
    real(kind=realtype) :: tempd8
    real(kind=realtype) :: tempd7
    real(kind=realtype) :: tempd6
    real(kind=realtype) :: tempd5
    real(kind=realtype) :: tempd4
    real(kind=realtype) :: tempd3
    real(kind=realtype) :: tempd2
    real(kind=realtype) :: tempd1
    real(kind=realtype) :: tempd0
    real(kind=realtype) :: temp
    real(kind=realtype) :: temp4
    refpoint(1) = lref*pointref(1)
    refpoint(2) = lref*pointref(2)
    refpoint(3) = lref*pointref(3)
    mredim = sqrt(pref*rhoref)
    internalflowfact = one
    if (flowtype .eq. internalflow) internalflowfact = -one
    inflowfact = one
    if (isinflow) inflowfact = -one
    if (withgathered) then
      sigma_ptotd = localvaluesd(isigmaptot)
      sigma_mnd = localvaluesd(isigmamn)
      mass_ptotd = 0.0_8
      mmomd = 0.0_8
      mass_psd = 0.0_8
      mass_mnd = 0.0_8
      mass_ttotd = 0.0_8
      fpd = 0.0_8
      pkd = 0.0_8
      fmomd = 0.0_8
      massflowrated = 0.0_8
      mpd = 0.0_8
    else
      mmomd = 0.0_8
      mmomd = localvaluesd(iflowmm:iflowmm+2)
      mpd = 0.0_8
      mpd = localvaluesd(iflowmp:iflowmp+2)
      fmomd = 0.0_8
      fmomd = localvaluesd(iflowfm:iflowfm+2)
      fpd = 0.0_8
      fpd = localvaluesd(ifp:ifp+2)
      pkd = localvaluesd(ipk)
      mass_mnd = localvaluesd(imassmn)
      mass_psd = localvaluesd(imassps)
      mass_ttotd = localvaluesd(imassttot)
      mass_ptotd = localvaluesd(imassptot)
      massflowrated = localvaluesd(imassflow)
      sigma_mnd = 0.0_8
      sigma_ptotd = 0.0_8
    end if
    mredimd = 0.0_8
    normd = 0.0_8
    ptotd = 0.0_8
    refpointd = 0.0_8
    gammamd = 0.0_8
    ttotd = 0.0_8
    do i=1,size(conn, 2)
      res = faminlist(fams(i), famlist)
      if (res) then
! compute the averaged values for this trianlge
        vxm = zero
        vym = zero
        vzm = zero
        rhom = zero
        pm = zero
        sf = zero
        do j=1,3
          rhom = rhom + vars(conn(j, i), irho)
          vxm = vxm + vars(conn(j, i), ivx)
          vym = vym + vars(conn(j, i), ivy)
          vzm = vzm + vars(conn(j, i), ivz)
          pm = pm + vars(conn(j, i), irhoe)
          gammam = gammam + vars(conn(j, i), izippflowgamma)
          sf = sf + vars(conn(j, i), izippflowsface)
        end do
! divide by 3 due to the summation above:
        rhom = third*rhom
        vxm = third*vxm
        vym = third*vym
        vzm = third*vzm
        pm = third*pm
        gammam = third*gammam
        sf = third*sf
! get the nodes of triangle.
        x1 = vars(conn(1, i), izippflowx:izippflowz)
        x2 = vars(conn(2, i), izippflowx:izippflowz)
        x3 = vars(conn(3, i), izippflowx:izippflowz)
        arg1(:) = x2 - x1
        arg2(:) = x3 - x1
        call cross_prod(arg1(:), arg2(:), norm)
        ss = half*norm
        call computeptot(rhom, vxm, vym, vzm, pm, ptot)
        call computettot(rhom, vxm, vym, vzm, pm, ttot)
        vnm = vxm*ss(1) + vym*ss(2) + vzm*ss(3) - sf
        vmag = sqrt(vxm**2 + vym**2 + vzm**2) - sf
! a = sqrt(gamma*p/rho); sqrt(v**2/a**2)
        mnm = vmag/sqrt(gammam*pm/rhom)
        massflowratelocal = rhom*vnm*mredim
        if (withgathered) then
          tempd2 = massflowratelocal*2*(ptot-funcvalues(costfuncmavgptot&
&           ))*sigma_ptotd
          massflowratelocald = (mnm-funcvalues(costfuncmavgmn))**2*&
&           sigma_mnd + (ptot-funcvalues(costfuncmavgptot))**2*&
&           sigma_ptotd
          ptotd = ptotd + tempd2
          funcvaluesd(costfuncmavgptot) = funcvaluesd(costfuncmavgptot) &
&           - tempd2
          tempd3 = massflowratelocal*2*(mnm-funcvalues(costfuncmavgmn))*&
&           sigma_mnd
          mnmd = tempd3
          funcvaluesd(costfuncmavgmn) = funcvaluesd(costfuncmavgmn) - &
&           tempd3
          vnmd = 0.0_8
          vxmd = 0.0_8
          vymd = 0.0_8
          rhomd = 0.0_8
          ssd = 0.0_8
          pmd = 0.0_8
          vzmd = 0.0_8
          vmagd = 0.0_8
        else
          call pushreal8(pm)
          pm = pm*pref
! compute the average cell center. 
          xc = zero
          yc = zero
          zc = zero
          do j=1,3
            xc = xc + vars(conn(1, i), izippflowx)
            yc = yc + vars(conn(2, i), izippflowy)
            zc = zc + vars(conn(3, i), izippflowz)
          end do
! finish average for cell center
          xc = third*xc
          yc = third*yc
          zc = third*zc
          xc = xc - refpoint(1)
          yc = yc - refpoint(2)
          zc = zc - refpoint(3)
          call pushreal8(pm)
          pm = -(pm-pinf*pref)
! update the pressure force and moment coefficients.
! momentum forces
! get unit normal vector. 
          result1 = mynorm2(ss)
          call pushreal8array(ss, 3)
          ss = ss/result1
          call pushreal8(massflowratelocal)
          massflowratelocal = massflowratelocal/timeref*internalflowfact&
&           *inflowfact
          fx = massflowratelocal*ss(1)*vxm/timeref
          fy = massflowratelocal*ss(2)*vym/timeref
          fz = massflowratelocal*ss(3)*vzm/timeref
          temp2 = ss(1)/timeref
          temp3 = ss(2)/timeref
          mzd = mmomd(3)
          myd = mmomd(2)
          mxd = mmomd(1)
          xcd = fy*mzd - fz*myd
          fyd = xc*mzd - fmomd(2) - zc*mxd
          ycd = fz*mxd - fx*mzd
          fxd = zc*myd - fmomd(1) - yc*mzd
          zcd = fx*myd - fy*mxd
          fzd = yc*mxd - fmomd(3) - xc*myd
          ssd = 0.0_8
          tempd6 = massflowratelocal*vzm*fzd/timeref
          temp4 = ss(3)/timeref
          ssd(3) = ssd(3) + tempd6
          massflowratelocald = temp3*vym*fyd + temp2*vxm*fxd + temp4*vzm&
&           *fzd
          vzmd = temp4*massflowratelocal*fzd
          tempd7 = massflowratelocal*vym*fyd/timeref
          ssd(2) = ssd(2) + tempd7
          vymd = temp3*massflowratelocal*fyd
          tempd9 = massflowratelocal*vxm*fxd/timeref
          ssd(1) = ssd(1) + tempd9
          vxmd = temp2*massflowratelocal*fxd
          call popreal8(massflowratelocal)
          tempd8 = internalflowfact*inflowfact*massflowratelocald/&
&           timeref
          timerefd = timerefd - temp3*tempd7 - massflowratelocal*tempd8/&
&           timeref - temp2*tempd9 - temp4*tempd6
          massflowratelocald = tempd8
          call popreal8array(ss, 3)
          result1d = sum(-(ss*ssd/result1))/result1
          ssd = ssd/result1
          call mynorm2_b(ss, ssd, result1d)
          mzd = mpd(3)
          myd = mpd(2)
          mxd = mpd(1)
          fx = pm*ss(1)
          fy = pm*ss(2)
          fyd = fpd(2) - zc*mxd + xc*mzd
          fxd = zc*myd + fpd(1) - yc*mzd
          fz = pm*ss(3)
          xcd = xcd + fy*mzd - fz*myd
          ycd = ycd + fz*mxd - fx*mzd
          zcd = zcd + fx*myd - fy*mxd
          fzd = yc*mxd + fpd(3) - xc*myd
          pmd = ss(2)*fyd + ss(1)*fxd + ss(3)*fzd
          ssd(3) = ssd(3) + pm*fzd
          ssd(2) = ssd(2) + pm*fyd
          ssd(1) = ssd(1) + pm*fxd
          call popreal8(pm)
          prefd = prefd + pinf*pmd
          pmd = -pmd
          refpointd(3) = refpointd(3) - zcd
          refpointd(2) = refpointd(2) - ycd
          refpointd(1) = refpointd(1) - xcd
          zcd = third*zcd
          ycd = third*ycd
          xcd = third*xcd
          do j=3,1,-1
            varsd(conn(3, i), izippflowz) = varsd(conn(3, i), izippflowz&
&             ) + zcd
            varsd(conn(2, i), izippflowy) = varsd(conn(2, i), izippflowy&
&             ) + ycd
            varsd(conn(1, i), izippflowx) = varsd(conn(1, i), izippflowx&
&             ) + xcd
          end do
          mnmd = massflowratelocal*mass_mnd
          massflowratelocald = massflowratelocald + pm*mass_psd + pref*&
&           ptot*mass_ptotd + massflowrated + tref*ttot*mass_ttotd + mnm&
&           *mass_mnd
          pmd = pmd + massflowratelocal*mass_psd
          ttotd = ttotd + tref*massflowratelocal*mass_ttotd
          trefd = trefd + ttot*massflowratelocal*mass_ttotd
          ptotd = ptotd + pref*massflowratelocal*mass_ptotd
          call popreal8(pm)
          temp1 = vmag**2 - uinf**2
          tempd5 = uref*vnm*pref*pkd
          tempd4 = uref*(pm-pinf+half*(rhom*temp1))*pkd
          prefd = prefd + pm*pmd + vnm*tempd4 + ptot*massflowratelocal*&
&           mass_ptotd
          pmd = tempd5 + pref*pmd
          rhomd = half*temp1*tempd5
          vmagd = rhom*half*2*vmag*tempd5
          vnmd = pref*tempd4
        end if
        temp = gammam*pm/rhom
        temp0 = sqrt(temp)
        if (temp .eq. 0.0_8) then
          tempd0 = 0.0
        else
          tempd0 = -(vmag*mnmd/(2.0*temp0**3*rhom))
        end if
        rhomd = rhomd + mredim*vnm*massflowratelocald - temp*tempd0
        vnmd = vnmd + mredim*rhom*massflowratelocald
        mredimd = mredimd + rhom*vnm*massflowratelocald
        vmagd = vmagd + mnmd/temp0
        gammamd = gammamd + pm*tempd0
        pmd = pmd + gammam*tempd0
        if (vxm**2 + vym**2 + vzm**2 .eq. 0.0_8) then
          tempd1 = 0.0
        else
          tempd1 = vmagd/(2.0*sqrt(vxm**2+vym**2+vzm**2))
        end if
        vxmd = vxmd + ss(1)*vnmd + 2*vxm*tempd1
        vymd = vymd + ss(2)*vnmd + 2*vym*tempd1
        vzmd = vzmd + ss(3)*vnmd + 2*vzm*tempd1
        sfd = -vnmd - vmagd
        ssd(1) = ssd(1) + vxm*vnmd
        ssd(2) = ssd(2) + vym*vnmd
        ssd(3) = ssd(3) + vzm*vnmd
        call computettot_b(rhom, rhomd, vxm, vxmd, vym, vymd, vzm, vzmd&
&                    , pm, pmd, ttot, ttotd)
        call computeptot_b(rhom, rhomd, vxm, vxmd, vym, vymd, vzm, vzmd&
&                    , pm, pmd, ptot, ptotd)
        normd = normd + half*ssd
        call cross_prod_b(arg1(:), arg1d(:), arg2(:), arg2d(:), norm, &
&                   normd)
        x1d = 0.0_8
        x3d = 0.0_8
        x3d = arg2d(:)
        x1d = -arg1d(:) - arg2d(:)
        x2d = 0.0_8
        x2d = arg1d(:)
        varsd(conn(3, i), izippflowx:izippflowz) = varsd(conn(3, i), &
&         izippflowx:izippflowz) + x3d
        varsd(conn(2, i), izippflowx:izippflowz) = varsd(conn(2, i), &
&         izippflowx:izippflowz) + x2d
        varsd(conn(1, i), izippflowx:izippflowz) = varsd(conn(1, i), &
&         izippflowx:izippflowz) + x1d
        sfd = third*sfd
        gammamd = third*gammamd
        pmd = third*pmd
        vzmd = third*vzmd
        vymd = third*vymd
        vxmd = third*vxmd
        rhomd = third*rhomd
        do j=3,1,-1
          varsd(conn(j, i), izippflowsface) = varsd(conn(j, i), &
&           izippflowsface) + sfd
          varsd(conn(j, i), izippflowgamma) = varsd(conn(j, i), &
&           izippflowgamma) + gammamd
          varsd(conn(j, i), irhoe) = varsd(conn(j, i), irhoe) + pmd
          varsd(conn(j, i), ivz) = varsd(conn(j, i), ivz) + vzmd
          varsd(conn(j, i), ivy) = varsd(conn(j, i), ivy) + vymd
          varsd(conn(j, i), ivx) = varsd(conn(j, i), ivx) + vxmd
          varsd(conn(j, i), irho) = varsd(conn(j, i), irho) + rhomd
        end do
      end if
    end do
    if (pref*rhoref .eq. 0.0_8) then
      tempd = 0.0
    else
      tempd = mredimd/(2.0*sqrt(pref*rhoref))
    end if
    prefd = prefd + rhoref*tempd
    rhorefd = rhorefd + pref*tempd
    pointrefd(3) = pointrefd(3) + lref*refpointd(3)
    refpointd(3) = 0.0_8
    pointrefd(2) = pointrefd(2) + lref*refpointd(2)
    refpointd(2) = 0.0_8
    pointrefd(1) = pointrefd(1) + lref*refpointd(1)
  end subroutine flowintegrationzipper_b
  subroutine flowintegrationzipper(isinflow, conn, fams, vars, &
&   localvalues, famlist, sps, withgathered, funcvalues)
! integrate over the trianges for the inflow/outflow conditions. 
    use constants
    use blockpointers, only : bctype
    use sorting, only : faminlist
    use flowvarrefstate, only : pref, pinf, rhoref, pref, timeref, &
&   lref, tref, rgas, uref, uinf
    use inputphysics, only : pointref, flowtype
    use flowutils_b, only : computeptot, computettot
    use surfacefamilies, only : familyexchange, bcfamexchange
    use utils_b, only : mynorm2, cross_prod
    implicit none
! input/output variables
    logical, intent(in) :: isinflow
    integer(kind=inttype), dimension(:, :), intent(in) :: conn
    integer(kind=inttype), dimension(:), intent(in) :: fams
    real(kind=realtype), dimension(:, :), intent(in) :: vars
    real(kind=realtype), dimension(nlocalvalues), intent(inout) :: &
&   localvalues
    integer(kind=inttype), dimension(:), intent(in) :: famlist
    integer(kind=inttype), intent(in) :: sps
    logical, intent(in) :: withgathered
    real(kind=realtype), dimension(:), optional, intent(in) :: &
&   funcvalues
! working variables
    integer(kind=inttype) :: i, j
    real(kind=realtype) :: sf, vmag, vnm, vxm, vym, vzm, fx, fy, fz
    real(kind=realtype), dimension(3) :: fp, mp, fmom, mmom, refpoint, &
&   ss, x1, x2, x3, norm
    real(kind=realtype) :: pm, ptot, ttot, rhom, gammam, mnm, &
&   massflowratelocal
    real(kind=realtype) :: massflowrate, mass_ptot, mass_ttot, mass_ps, &
&   mass_mn
    real(kind=realtype) :: mredim, pk, sigma_mn, sigma_ptot
    real(kind=realtype) :: internalflowfact, inflowfact, xc, yc, zc, &
&   cellarea, mx, my, mz
    intrinsic sqrt
    intrinsic size
    real(kind=realtype), dimension(3) :: arg1
    real(kind=realtype), dimension(3) :: arg2
    real(kind=realtype) :: result1
    massflowrate = zero
    mass_ptot = zero
    mass_ttot = zero
    mass_ps = zero
    refpoint(1) = lref*pointref(1)
    refpoint(2) = lref*pointref(2)
    refpoint(3) = lref*pointref(3)
    mredim = sqrt(pref*rhoref)
    fp = zero
    mp = zero
    fmom = zero
    mmom = zero
    internalflowfact = one
    if (flowtype .eq. internalflow) internalflowfact = -one
    inflowfact = one
    if (isinflow) inflowfact = -one
    do i=1,size(conn, 2)
      if (faminlist(fams(i), famlist)) then
! compute the averaged values for this trianlge
        vxm = zero
        vym = zero
        vzm = zero
        rhom = zero
        pm = zero
        mnm = zero
        sf = zero
        do j=1,3
          rhom = rhom + vars(conn(j, i), irho)
          vxm = vxm + vars(conn(j, i), ivx)
          vym = vym + vars(conn(j, i), ivy)
          vzm = vzm + vars(conn(j, i), ivz)
          pm = pm + vars(conn(j, i), irhoe)
          gammam = gammam + vars(conn(j, i), izippflowgamma)
          sf = sf + vars(conn(j, i), izippflowsface)
        end do
! divide by 3 due to the summation above:
        rhom = third*rhom
        vxm = third*vxm
        vym = third*vym
        vzm = third*vzm
        pm = third*pm
        gammam = third*gammam
        sf = third*sf
! get the nodes of triangle.
        x1 = vars(conn(1, i), izippflowx:izippflowz)
        x2 = vars(conn(2, i), izippflowx:izippflowz)
        x3 = vars(conn(3, i), izippflowx:izippflowz)
        arg1(:) = x2 - x1
        arg2(:) = x3 - x1
        call cross_prod(arg1(:), arg2(:), norm)
        ss = half*norm
        call computeptot(rhom, vxm, vym, vzm, pm, ptot)
        call computettot(rhom, vxm, vym, vzm, pm, ttot)
        vnm = vxm*ss(1) + vym*ss(2) + vzm*ss(3) - sf
        vmag = sqrt(vxm**2 + vym**2 + vzm**2) - sf
! a = sqrt(gamma*p/rho); sqrt(v**2/a**2)
        mnm = vmag/sqrt(gammam*pm/rhom)
        massflowratelocal = rhom*vnm*mredim
        if (withgathered) then
          sigma_mn = sigma_mn + massflowratelocal*(mnm-funcvalues(&
&           costfuncmavgmn))**2
          sigma_ptot = sigma_ptot + massflowratelocal*(ptot-funcvalues(&
&           costfuncmavgptot))**2
        else
          massflowrate = massflowrate + massflowratelocal
          pk = pk + (pm-pinf+half*rhom*(vmag**2-uinf**2))*vnm*pref*uref
          pm = pm*pref
          mass_ptot = mass_ptot + ptot*massflowratelocal*pref
          mass_ttot = mass_ttot + ttot*massflowratelocal*tref
          mass_ps = mass_ps + pm*massflowratelocal
          mass_mn = mass_mn + mnm*massflowratelocal
! compute the average cell center. 
          xc = zero
          yc = zero
          zc = zero
          do j=1,3
            xc = xc + vars(conn(1, i), izippflowx)
            yc = yc + vars(conn(2, i), izippflowy)
            zc = zc + vars(conn(3, i), izippflowz)
          end do
! finish average for cell center
          xc = third*xc
          yc = third*yc
          zc = third*zc
          xc = xc - refpoint(1)
          yc = yc - refpoint(2)
          zc = zc - refpoint(3)
          pm = -(pm-pinf*pref)
          fx = pm*ss(1)
          fy = pm*ss(2)
          fz = pm*ss(3)
! update the pressure force and moment coefficients.
          fp(1) = fp(1) + fx
          fp(2) = fp(2) + fy
          fp(3) = fp(3) + fz
          mx = yc*fz - zc*fy
          my = zc*fx - xc*fz
          mz = xc*fy - yc*fx
          mp(1) = mp(1) + mx
          mp(2) = mp(2) + my
          mp(3) = mp(3) + mz
! momentum forces
! get unit normal vector. 
          result1 = mynorm2(ss)
          ss = ss/result1
          massflowratelocal = massflowratelocal/timeref*internalflowfact&
&           *inflowfact
          fx = massflowratelocal*ss(1)*vxm/timeref
          fy = massflowratelocal*ss(2)*vym/timeref
          fz = massflowratelocal*ss(3)*vzm/timeref
          fmom(1) = fmom(1) - fx
          fmom(2) = fmom(2) - fy
          fmom(3) = fmom(3) - fz
          mx = yc*fz - zc*fy
          my = zc*fx - xc*fz
          mz = xc*fy - yc*fx
          mmom(1) = mmom(1) + mx
          mmom(2) = mmom(2) + my
          mmom(3) = mmom(3) + mz
        end if
      end if
    end do
    if (withgathered) then
      localvalues(isigmamn) = localvalues(isigmamn) + sigma_mn
      localvalues(isigmaptot) = localvalues(isigmaptot) + sigma_ptot
    else
! increment the local values array with what we computed here
      localvalues(imassflow) = localvalues(imassflow) + massflowrate
      localvalues(imassptot) = localvalues(imassptot) + mass_ptot
      localvalues(imassttot) = localvalues(imassttot) + mass_ttot
      localvalues(imassps) = localvalues(imassps) + mass_ps
      localvalues(imassmn) = localvalues(imassmn) + mass_mn
      localvalues(ipk) = localvalues(ipk) + pk
      localvalues(ifp:ifp+2) = localvalues(ifp:ifp+2) + fp
      localvalues(iflowfm:iflowfm+2) = localvalues(iflowfm:iflowfm+2) + &
&       fmom
      localvalues(iflowmp:iflowmp+2) = localvalues(iflowmp:iflowmp+2) + &
&       mp
      localvalues(iflowmm:iflowmm+2) = localvalues(iflowmm:iflowmm+2) + &
&       mmom
    end if
  end subroutine flowintegrationzipper
!  differentiation of wallintegrationzipper in reverse (adjoint) mode (with options i4 dr8 r8 noisize):
!   gradient     of useful results: pointref vars localvalues
!   with respect to varying inputs: pointref vars localvalues
!   rw status of diff variables: pointref:incr vars:incr localvalues:in-out
  subroutine wallintegrationzipper_b(conn, fams, vars, varsd, &
&   localvalues, localvaluesd, famlist, sps)
    use constants
    use sorting, only : faminlist
    use flowvarrefstate, only : lref
    use inputphysics, only : pointref, pointrefd
    use utils_b, only : mynorm2, mynorm2_b, cross_prod, cross_prod_b
    implicit none
! input/output
    integer(kind=inttype), dimension(:, :), intent(in) :: conn
    integer(kind=inttype), dimension(:), intent(in) :: fams
    real(kind=realtype), dimension(:, :), intent(in) :: vars
    real(kind=realtype), dimension(:, :) :: varsd
    real(kind=realtype), intent(inout) :: localvalues(nlocalvalues)
    real(kind=realtype) :: localvaluesd(nlocalvalues)
    integer(kind=inttype), dimension(:), intent(in) :: famlist
    integer(kind=inttype), intent(in) :: sps
! working
    real(kind=realtype), dimension(3) :: fp, fv, mp, mv
    real(kind=realtype), dimension(3) :: fpd, fvd, mpd, mvd
    integer(kind=inttype) :: i, j
    real(kind=realtype), dimension(3) :: ss, norm, refpoint
    real(kind=realtype), dimension(3) :: ssd, normd, refpointd
    real(kind=realtype), dimension(3) :: p1, p2, p3, v1, v2, v3, x1, x2&
&   , x3
    real(kind=realtype), dimension(3) :: p1d, p2d, p3d, v1d, v2d, v3d, &
&   x1d, x2d, x3d
    real(kind=realtype) :: fact, triarea, fx, fy, fz, mx, my, mz, xc, yc&
&   , zc
    real(kind=realtype) :: triaread, fxd, fyd, fzd, mxd, myd, mzd, xcd, &
&   ycd, zcd
    intrinsic size
    real(kind=realtype), dimension(3) :: arg1
    real(kind=realtype), dimension(3) :: arg1d
    real(kind=realtype), dimension(3) :: arg2
    real(kind=realtype), dimension(3) :: arg2d
    real(kind=realtype) :: result1
    real(kind=realtype) :: result1d
    logical :: res
    real(kind=realtype) :: tempd
    real(kind=realtype) :: tempd7
    real(kind=realtype) :: tempd6
    real(kind=realtype) :: tempd5
    real(kind=realtype) :: tempd4
    real(kind=realtype) :: tempd3
    real(kind=realtype) :: tempd2
    real(kind=realtype) :: tempd1
    real(kind=realtype) :: tempd0
! determine the reference point for the moment computation in
! meters.
    refpoint(1) = lref*pointref(1)
    refpoint(2) = lref*pointref(2)
    refpoint(3) = lref*pointref(3)
    mvd = 0.0_8
    mvd = localvaluesd(imv:imv+2)
    mpd = 0.0_8
    mpd = localvaluesd(imp:imp+2)
    fvd = 0.0_8
    fvd = localvaluesd(ifv:ifv+2)
    fpd = 0.0_8
    fpd = localvaluesd(ifp:ifp+2)
    normd = 0.0_8
    refpointd = 0.0_8
    do i=1,size(conn, 2)
      res = faminlist(fams(i), famlist)
      if (res) then
! get the nodes of triangle. the *3 is becuase of the
! blanket third above. 
        x1 = vars(conn(1, i), izippwallx:izippwallz)
        x2 = vars(conn(2, i), izippwallx:izippwallz)
        x3 = vars(conn(3, i), izippwallx:izippwallz)
        arg1(:) = x2 - x1
        arg2(:) = x3 - x1
        call cross_prod(arg1(:), arg2(:), norm)
        ss = half*norm
! the third here is to account for the summation of p1, p2
! and p3
        result1 = mynorm2(ss)
        triarea = result1*third
! compute the average cell center. 
        xc = third*(x1(1)+x2(1)+x3(1))
        yc = third*(x1(2)+x2(2)+x3(2))
        zc = third*(x1(3)+x2(3)+x3(3))
        xc = xc - refpoint(1)
        yc = yc - refpoint(2)
        zc = zc - refpoint(3)
! update the pressure force and moment coefficients.
        p1 = vars(conn(1, i), izippwalltpx:izippwalltpz)
        p2 = vars(conn(2, i), izippwalltpx:izippwalltpz)
        p3 = vars(conn(3, i), izippwalltpx:izippwalltpz)
! update the viscous force and moment coefficients
        v1 = vars(conn(1, i), izippwalltvx:izippwalltvz)
        v2 = vars(conn(2, i), izippwalltvx:izippwalltvz)
        v3 = vars(conn(3, i), izippwalltvx:izippwalltvz)
        fx = (v1(1)+v2(1)+v3(1))*triarea
        fy = (v1(2)+v2(2)+v3(2))*triarea
        fz = (v1(3)+v2(3)+v3(3))*triarea
! note: momentum forces have opposite sign to pressure forces
        mzd = mvd(3)
        myd = mvd(2)
        mxd = mvd(1)
        xcd = fy*mzd - fz*myd
        fyd = fvd(2) - zc*mxd + xc*mzd
        ycd = fz*mxd - fx*mzd
        fxd = zc*myd + fvd(1) - yc*mzd
        zcd = fx*myd - fy*mxd
        fzd = yc*mxd + fvd(3) - xc*myd
        v1d = 0.0_8
        v2d = 0.0_8
        v3d = 0.0_8
        tempd = triarea*fzd
        v1d(3) = v1d(3) + tempd
        v2d(3) = v2d(3) + tempd
        v3d(3) = v3d(3) + tempd
        triaread = (v1(2)+v2(2)+v3(2))*fyd + (v1(1)+v2(1)+v3(1))*fxd + (&
&         v1(3)+v2(3)+v3(3))*fzd
        tempd0 = triarea*fyd
        v1d(2) = v1d(2) + tempd0
        v2d(2) = v2d(2) + tempd0
        v3d(2) = v3d(2) + tempd0
        tempd1 = triarea*fxd
        v1d(1) = v1d(1) + tempd1
        v2d(1) = v2d(1) + tempd1
        v3d(1) = v3d(1) + tempd1
        varsd(conn(3, i), izippwalltvx:izippwalltvz) = varsd(conn(3, i)&
&         , izippwalltvx:izippwalltvz) + v3d
        varsd(conn(2, i), izippwalltvx:izippwalltvz) = varsd(conn(2, i)&
&         , izippwalltvx:izippwalltvz) + v2d
        varsd(conn(1, i), izippwalltvx:izippwalltvz) = varsd(conn(1, i)&
&         , izippwalltvx:izippwalltvz) + v1d
        mzd = mpd(3)
        myd = mpd(2)
        mxd = mpd(1)
        fx = (p1(1)+p2(1)+p3(1))*triarea
        fy = (p1(2)+p2(2)+p3(2))*triarea
        fyd = fpd(2) - zc*mxd + xc*mzd
        fxd = zc*myd + fpd(1) - yc*mzd
        fz = (p1(3)+p2(3)+p3(3))*triarea
        xcd = xcd + fy*mzd - fz*myd
        ycd = ycd + fz*mxd - fx*mzd
        zcd = zcd + fx*myd - fy*mxd
        fzd = yc*mxd + fpd(3) - xc*myd
        p1d = 0.0_8
        p2d = 0.0_8
        p3d = 0.0_8
        tempd2 = triarea*fzd
        p1d(3) = p1d(3) + tempd2
        p2d(3) = p2d(3) + tempd2
        p3d(3) = p3d(3) + tempd2
        triaread = triaread + (p1(2)+p2(2)+p3(2))*fyd + (p1(1)+p2(1)+p3(&
&         1))*fxd + (p1(3)+p2(3)+p3(3))*fzd
        tempd3 = triarea*fyd
        p1d(2) = p1d(2) + tempd3
        p2d(2) = p2d(2) + tempd3
        p3d(2) = p3d(2) + tempd3
        tempd4 = triarea*fxd
        p1d(1) = p1d(1) + tempd4
        p2d(1) = p2d(1) + tempd4
        p3d(1) = p3d(1) + tempd4
        varsd(conn(3, i), izippwalltpx:izippwalltpz) = varsd(conn(3, i)&
&         , izippwalltpx:izippwalltpz) + p3d
        varsd(conn(2, i), izippwalltpx:izippwalltpz) = varsd(conn(2, i)&
&         , izippwalltpx:izippwalltpz) + p2d
        varsd(conn(1, i), izippwalltpx:izippwalltpz) = varsd(conn(1, i)&
&         , izippwalltpx:izippwalltpz) + p1d
        refpointd(3) = refpointd(3) - zcd
        refpointd(2) = refpointd(2) - ycd
        refpointd(1) = refpointd(1) - xcd
        x1d = 0.0_8
        x2d = 0.0_8
        x3d = 0.0_8
        tempd5 = third*zcd
        x1d(3) = x1d(3) + tempd5
        x2d(3) = x2d(3) + tempd5
        x3d(3) = x3d(3) + tempd5
        tempd6 = third*ycd
        x1d(2) = x1d(2) + tempd6
        x2d(2) = x2d(2) + tempd6
        x3d(2) = x3d(2) + tempd6
        tempd7 = third*xcd
        x1d(1) = x1d(1) + tempd7
        x2d(1) = x2d(1) + tempd7
        x3d(1) = x3d(1) + tempd7
        result1d = third*triaread
        ssd = 0.0_8
        call mynorm2_b(ss, ssd, result1d)
        normd = normd + half*ssd
        call cross_prod_b(arg1(:), arg1d(:), arg2(:), arg2d(:), norm, &
&                   normd)
        x3d = x3d + arg2d
        x1d = x1d - arg1d - arg2d
        x2d = x2d + arg1d
        varsd(conn(3, i), izippwallx:izippwallz) = varsd(conn(3, i), &
&         izippwallx:izippwallz) + x3d
        varsd(conn(2, i), izippwallx:izippwallz) = varsd(conn(2, i), &
&         izippwallx:izippwallz) + x2d
        varsd(conn(1, i), izippwallx:izippwallz) = varsd(conn(1, i), &
&         izippwallx:izippwallz) + x1d
      end if
    end do
    pointrefd(3) = pointrefd(3) + lref*refpointd(3)
    refpointd(3) = 0.0_8
    pointrefd(2) = pointrefd(2) + lref*refpointd(2)
    refpointd(2) = 0.0_8
    pointrefd(1) = pointrefd(1) + lref*refpointd(1)
  end subroutine wallintegrationzipper_b
  subroutine wallintegrationzipper(conn, fams, vars, localvalues, &
&   famlist, sps)
    use constants
    use sorting, only : faminlist
    use flowvarrefstate, only : lref
    use inputphysics, only : pointref
    use utils_b, only : mynorm2, cross_prod
    implicit none
! input/output
    integer(kind=inttype), dimension(:, :), intent(in) :: conn
    integer(kind=inttype), dimension(:), intent(in) :: fams
    real(kind=realtype), dimension(:, :), intent(in) :: vars
    real(kind=realtype), intent(inout) :: localvalues(nlocalvalues)
    integer(kind=inttype), dimension(:), intent(in) :: famlist
    integer(kind=inttype), intent(in) :: sps
! working
    real(kind=realtype), dimension(3) :: fp, fv, mp, mv
    integer(kind=inttype) :: i, j
    real(kind=realtype), dimension(3) :: ss, norm, refpoint
    real(kind=realtype), dimension(3) :: p1, p2, p3, v1, v2, v3, x1, x2&
&   , x3
    real(kind=realtype) :: fact, triarea, fx, fy, fz, mx, my, mz, xc, yc&
&   , zc
    intrinsic size
    real(kind=realtype), dimension(3) :: arg1
    real(kind=realtype), dimension(3) :: arg2
    real(kind=realtype) :: result1
! determine the reference point for the moment computation in
! meters.
    refpoint(1) = lref*pointref(1)
    refpoint(2) = lref*pointref(2)
    refpoint(3) = lref*pointref(3)
    fp = zero
    fv = zero
    mp = zero
    mv = zero
    do i=1,size(conn, 2)
      if (faminlist(fams(i), famlist)) then
! get the nodes of triangle. the *3 is becuase of the
! blanket third above. 
        x1 = vars(conn(1, i), izippwallx:izippwallz)
        x2 = vars(conn(2, i), izippwallx:izippwallz)
        x3 = vars(conn(3, i), izippwallx:izippwallz)
        arg1(:) = x2 - x1
        arg2(:) = x3 - x1
        call cross_prod(arg1(:), arg2(:), norm)
        ss = half*norm
! the third here is to account for the summation of p1, p2
! and p3
        result1 = mynorm2(ss)
        triarea = result1*third
! compute the average cell center. 
        xc = third*(x1(1)+x2(1)+x3(1))
        yc = third*(x1(2)+x2(2)+x3(2))
        zc = third*(x1(3)+x2(3)+x3(3))
        xc = xc - refpoint(1)
        yc = yc - refpoint(2)
        zc = zc - refpoint(3)
! update the pressure force and moment coefficients.
        p1 = vars(conn(1, i), izippwalltpx:izippwalltpz)
        p2 = vars(conn(2, i), izippwalltpx:izippwalltpz)
        p3 = vars(conn(3, i), izippwalltpx:izippwalltpz)
        fx = (p1(1)+p2(1)+p3(1))*triarea
        fy = (p1(2)+p2(2)+p3(2))*triarea
        fz = (p1(3)+p2(3)+p3(3))*triarea
        fp(1) = fp(1) + fx
        fp(2) = fp(2) + fy
        fp(3) = fp(3) + fz
        mx = yc*fz - zc*fy
        my = zc*fx - xc*fz
        mz = xc*fy - yc*fx
        mp(1) = mp(1) + mx
        mp(2) = mp(2) + my
        mp(3) = mp(3) + mz
! update the viscous force and moment coefficients
        v1 = vars(conn(1, i), izippwalltvx:izippwalltvz)
        v2 = vars(conn(2, i), izippwalltvx:izippwalltvz)
        v3 = vars(conn(3, i), izippwalltvx:izippwalltvz)
        fx = (v1(1)+v2(1)+v3(1))*triarea
        fy = (v1(2)+v2(2)+v3(2))*triarea
        fz = (v1(3)+v2(3)+v3(3))*triarea
! note: momentum forces have opposite sign to pressure forces
        fv(1) = fv(1) + fx
        fv(2) = fv(2) + fy
        fv(3) = fv(3) + fz
        mx = yc*fz - zc*fy
        my = zc*fx - xc*fz
        mz = xc*fy - yc*fx
        mv(1) = mv(1) + mx
        mv(2) = mv(2) + my
        mv(3) = mv(3) + mz
      end if
    end do
! increment into the local vector
    localvalues(ifp:ifp+2) = localvalues(ifp:ifp+2) + fp
    localvalues(ifv:ifv+2) = localvalues(ifv:ifv+2) + fv
    localvalues(imp:imp+2) = localvalues(imp:imp+2) + mp
    localvalues(imv:imv+2) = localvalues(imv:imv+2) + mv
  end subroutine wallintegrationzipper
end module zipperintegrations_b

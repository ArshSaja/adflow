
!
!      ******************************************************************
!      *                                                                *
!      * File:          resetallxBwd.f90                                *
!      * Author:        Peter Zhoujie Lyu                               *
!      * Starting date: 11-03-2014                                      *
!      * Last modified: 11-03-2014                                      *
!      *                                                                *
!      ******************************************************************

subroutine resetallxBwd(nn, x0, x1, x2)                 

  use BCTypes
  use blockPointers
  implicit none
  !
  !      Subroutine arguments.
  !
  integer(kind=intType), intent(in) :: nn
  real(kind=realType), dimension(imaxDim,jmaxDim,3) :: x0, x1, x2
  !
  !      ******************************************************************
  !      *                                                                *
  !      * Begin execution                                                *
  !      *                                                                *
  !      ******************************************************************
  !
  ! Determine the face id on which the subface is located and set
  ! the pointers accordinly.
  select case (BCFaceID(nn))

  case (iMin)
     x(0,1:je,1:ke,:) = x0(1:je,1:ke,:)
     x(1,1:je,1:ke,:) = x1(1:je,1:ke,:)
     x(2,1:je,1:ke,:) = x2(1:je,1:ke,:)

     !===========================================================

  case (iMax)
     x(ie,1:je,1:ke,:) = x0(1:je,1:ke,:)
     x(il,1:je,1:ke,:) = x1(1:je,1:ke,:)
     x(nx,1:je,1:ke,:) = x2(1:je,1:ke,:)

     !===========================================================

  case (jMin)
     x(1:ie,0,1:ke,:) = x0(1:ie,1:ke,:)
     x(1:ie,1,1:ke,:) = x1(1:ie,1:ke,:)
     x(1:ie,2,1:ke,:) = x2(1:ie,1:ke,:)
 
     !===========================================================

  case (jMax)
     x(1:ie,je,1:ke,:) = x0(1:ie,1:ke,:)
     x(1:ie,jl,1:ke,:) = x1(1:ie,1:ke,:)
     x(1:ie,ny,1:ke,:) = x2(1:ie,1:ke,:)
 
     !===========================================================

  case (kMin)
     x(1:ie,1:je,0,:) = x0(1:ie,1:je,:)
     x(1:ie,1:je,1,:) = x1(1:ie,1:je,:)
     x(1:ie,1:je,2,:) = x2(1:ie,1:je,:)

     !===========================================================

  case (kMax)
      x(1:ie,1:je,ke,:) = x0(1:ie,1:je,:)
      x(1:ie,1:je,kl,:) = x1(1:ie,1:je,:)
      x(1:ie,1:je,nz,:) = x2(1:ie,1:je,:)

  end select
end subroutine resetallxBwd


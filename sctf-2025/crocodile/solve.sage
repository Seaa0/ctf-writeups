#!sage
from Crypto.Util.number import long_to_bytes
E = EllipticCurve(ComplexField(600),[ComplexField(600)(-1493709/1024+1199/16*ComplexField(600)("i")),ComplexField(600)(97809777/8192-82731/128*ComplexField(600)("i"))])
P = E.lift_x(ComplexField(600)(f"1.{int.from_bytes(b'Suna Suna','big')}+1.{int.from_bytes(b'no Mi','little')}*i"))
Q = E.lift_x(ComplexField(600)(36.4291990977855760916612664879030519474485549227993825161538502715951674771375534061669588110611144482794597140078219632113930698630358361379569599632450344672544557014134877316071 - 15.5094169179867261746136693539618921556037112420771075014010650669426508111314380331723075069743390329380360196986670381926994761597803212368978601671191064945527021806868498686789*I))

L = E.period_lattice()

omega1,omega2 = L.basis()

A,B = E.ainvs()[3:]

def weierstrass_p_inv(P):
    pari("\p 1000")
    pari(f"E = ellinit([{A}, {B}])")
    return ComplexField(667)(pari(f"ellpointtoz(E, [{P[0]}, {P[1]}])"))

Pu = weierstrass_p_inv(P)
Qu = weierstrass_p_inv(Q)

F = RealField(600)
z0r = QQ(F(Pu.real()))
z0i = QQ(F(Pu.imag_part()))
z1r = QQ(F(Qu.real()))
z1i = QQ(F(Qu.imag_part()))
omega1r = QQ(F(omega1.real()))
omega1i = QQ(F(omega1.imag_part()))
omega2r = QQ(F(omega2.real()))
omega2i = QQ(F(omega2.imag_part()))
L = Matrix(QQ,[[1,0,z0r,z0i],[0,1,-z1r,-z1i],[0,0,omega1r,omega1i],[0,0,omega2r,omega2i]])
L[:, -2:] *= 2**512
L[:, -3] *= 2**300
L = L.LLL()
L[:, -2:] /= 2**512
L[:, -3] /= 2**300

flag = long_to_bytes(abs(int(L[0][0]))).decode()
flag = 'sctf{'+flag+'}'
print(flag) # sctf{water_beats_sand!..in_arabasta,that_is}
# Crocodile
## Prerequisites
To understand this writeup, the following knowledge is required:
1. Basic group theory, including homomorphisms and isomorphisms
2. The group of points on an elliptic curve of the form $y^2=x^3+ax+b$
3. Complex numbers
4. Lattices and how to apply lattice basis reduction algorithms

With that being said, let's begin!
## The Challenge
We are given the challenge distribution as follows:
```py
assert str((int.from_bytes(input("sctf{").encode(),"big")*EllipticCurve(ComplexField(600),[ComplexField(600)(-1493709/1024+1199/16*ComplexField(600)("i")),ComplexField(600)(97809777/8192-82731/128*ComplexField(600)("i"))]).lift_x(ComplexField(600)(f"1.{int.from_bytes(b'Suna Suna','big')}+1.{int.from_bytes(b'no Mi','little')}*i")))[0])=='36.4291990977855760916612664879030519474485549227993825161538502715951674771375534061669588110611144482794597140078219632113930698630358361379569599632450344672544557014134877316071 - 15.5094169179867261746136693539618921556037112420771075014010650669426508111314380331723075069743390329380360196986670381926994761597803212368978601671191064945527021806868498686789*I' and not print('\033[43C\033[1A}')
```
We can vaguely identify that the challenge is to solve the Elliptic Curve Discrete Logarithm Problem (ECDLP) over a field of complex numbers, but this is still quite confusing. We can simplify the code into the below:
```py
flag = b'sctf{redacted}'.lstrip(b'sctf').rstrip(b'}')
E = EllipticCurve(ComplexField(600),[ComplexField(600)(-1493709/1024+1199/16*ComplexField(600)("i")),ComplexField(600)(97809777/8192-82731/128*ComplexField(600)("i"))])
P = E.lift_x(ComplexField(600)(f"1.{int.from_bytes(b'Suna Suna','big')}+1.{int.from_bytes(b'no Mi','little')}*i"))
Q = int.from_bytes(flag)*P
print(str(Q.xy()[0]))
# output: 36.4291990977855760916612664879030519474485549227993825161538502715951674771375534061669588110611144482794597140078219632113930698630358361379569599632450344672544557014134877316071 - 15.5094169179867261746136693539618921556037112420771075014010650669426508111314380331723075069743390329380360196986670381926994761597803212368978601671191064945527021806868498686789*I
```
Once again, this is a very standard ECDLP-breaking challenge, where the scalar is the flag, and with the clear vulnerability being that the numbers are over a complex field.  
## The Weierstrass-℘ Function
The Weierstrass-℘ Function, or the Weierstrass-p Function, which I will be referring to it by, is an infinite series which has terms depending on the equation of the elliptic curve which it concerns, and is also the solution to a specific differential equation. Said differential equation is unimportant so I will not be going into it.  
However, this function is important in that a complex number, $u$, can be mapped by an isomorphism, to a point on an elliptic curve $(℘(u),℘'(u))$.  

Since this is an isomorphism, there is an inverse, which we can accomplish with the following code:
```py
def weierstrass_p_inv(P):
    pari("\p 1000")
    pari(f"E = ellinit([{A}, {B}])")
    return ComplexField(667)(pari(f"ellpointtoz(E, [{P[0]}, {P[1]}])"))
```
where `A` and `B` are the coefficients in the equation of the elliptic curve $y^2=x^3+Ax+B$.

Hence, we can map elliptic curve point addition to point addition over numbers, just like in Smart's Attack, so we can just perform direction division...right? Well, not really.
## Periodicity
The function ℘ is doubly periodic. While that sounds abstract, let me illustrate with a simpler example.  
If $\sin(x) = y$, is $x = \sin^{-1}(y)$? No, $x = \sin^{-1}(y)+2k\pi, k \in \mathbb{Z}$. The $\sin$ function is singly periodic. Double periodicity means that there are two values of $\omega$ such that $℘(x+\omega) = ℘(x)$.
### Finding $\omega$
Finding the 2 values of $\omega$ is relatively easy, and can be done in newer versions of SageMath using the one-liner below:
```py
omega1, omega2 = E.period_lattice().basis()
```
The values of $\omega$ can be found by evaluating certain definite integrals, which I will not go into as we have already managed to find the values of $\omega$ through simpler means.
## Lattice Reduction
Now that we have the values of $\omega$, we have everything we need to solve the challenge! We can do so by using lattice reduction, or in particular, the Lenstra–Lenstra–Lovász (LLL) lattice basis reduction algorithm.  

Since LLL only returns results for integers on both the left-hand-side and right-hand-side vectors, it is perfect for our usage.  
But wait, LLL doesn't operate in complex numbers! Since we are only multiplying our complex numbers by real integers, we are only operating with addition over complex numbers. This means that complex numbers will behave exactly like degree-1 polynomials in terms of $i$. As we know, addition of polynomials is simply addition of coefficients, which means we can just use two separate columns of the lattice for our constraints.  

I ended up using the below lattice
$$\left[
  \begin{array}{cccc}
  1 & 0 & P_{real} & P_{imaginary} \\
  0 & 1 & -Q_{real} & -Q_{imaginary} \\
  0 & 0 & \omega_{1,real} & \omega_{1,imaginary} \\ 
  0 & 0 & \omega_{2,real} & \omega_{2,imaginary}
  \end{array}
\right]$$
This lattice should recover the vector
$$\left[
  \begin{array}{cccc}
  flag \\
  1 \\
  0 \\ 
  0
  \end{array}
\right]$$
After weighing the columns properly, we end up retreving the flag: `sctf{water_beats_sand!..in_arabasta,that_is}`. Truly a _One Piece_ reference.  

We can verify that it indeed passes the `assert` test in the challenge code.
## Solve Script
Solve script in `solve.sage`.
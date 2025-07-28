## YunliRegularity
Repository containing [Macaulay2](https://macaulay2.com/) code that computes the [Castelnuovo-Mumford regularity](https://en.wikipedia.org/wiki/Castelnuovo%E2%80%93Mumford_regularity) of the edge ideals of graphs, where each vertex variable may have degree greater than one.
The code is designed to be inserted into the [init.m2 file](https://macaulay2.com/doc/Macaulay2/share/doc/Macaulay2/Macaulay2Doc/html/_initialization_spfile.html) of a Macaulay2 installation, so that the functions can be used in a local Macaulay2 session.

## Functions
- **Regularity** `r(E)`\
Computes the ordinary Castelnuovo-Mumford regularity of a graph.
    - `E`: The edge set. A list of two-integer lists. The integers must be a consecutive range of integers starting from `0`. 
- **Regularity Offset** `ro(E, D)`\
 Computes the regularity offset of a graph `E` with vertex degrees `D`. The regularity offset is defined to be `reg I(G) + n - reg J(G)`, where `I(G)` is the ordinary edge ideal of the graph `G`, `n` is the total number of extra degrees of the vertices, and `J(G)` is the edge ideal taking into account the degrees of each vertex.
  - `E`: The edge set. A list of two-integer lists. The integers must be a consecutive range of integers starting from `0`. 
  - `D`: The degree list. Must be a list of integers. Length must be equal to the number of vertices.
- **Show Regularity Offset** `sro(E, N)` `sro(E, N, L)` `sro(E, C, N)` `sro(E, N, L, C)`\
Computes the regularity offset of a graph, traversing through all possible degree additions to the vertices.
  - `E`: The edge set. A list of two-integer lists. The integers must be a consecutive range of integers starting from `0`. 
  - `N`: The maximum total degrees added to the vertices.
  - `L`: A subset of the vertices to add degrees to. Defaults to `{}`, which causes degrees to be added to all vertices.
  - `C`: A tropical polynomial.
- **Star** `st(L)`\
Returns the edge set of a star graph.
  - `L`: A list of integers consisting of the lengths of each limb of the star.
- **Resolution Show** `rs(E)`\
Prints the minimal resolution of a graph, showing the multi-degrees of every generator of every module and the coefficient matrix of every differential,
  - `E`: The edge set. A list of two-integer lists. The integers must be a consecutive range of integers starting from `0`. 
- **Complement Edges** `ce(E)`\
Returns the edge set of the complement graph of `E`.
  - `E`: The edge set. A list of two-integer lists. The integers must be a consecutive range of integers starting from `0`. 
- **Random Edges** `re(V, N)`\
Returns a random edge set with `V` vertices and `N` edges.
- **Offset Graph** `og(V, N)` `og(V)`\
Returns a list of graphs with `V` vertices and `N` edges (if specified) that have nonzero regularity offset.

## 云璃
仙舟「朱明」的猎剑士，备受「烛渊将军」怀炎宠爱的孙女，性格直率。\
从小跟随怀炎学习剑艺与锻艺，乃「焰轮八叶」中次年幼的天才剑士。\
对朱明流出的魔剑深恶痛绝，立誓要「搜猎魔剑，尽数断绝」。
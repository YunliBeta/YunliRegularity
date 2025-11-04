needsPackage "EdgeIdeals";
needsPackage "SymbolicPowers";
needsPackage "LocalRings";
needsPackage "FourTiTwo";

createLists = (listLength, listSum) -> (

    retList := {};

    if listLength == 1 then (

        {{listSum}}

    ) else (

        for i from 0 to listSum do (
            remaining := createLists(listLength - 1, listSum - i);
            for item in remaining do (
                retList = append(retList, {i} | item);
            );
        );

        retList

    )

);

regularityCore = E -> (

    V := #(unique flatten E);

    R := QQ[x_0..x_(V - 1)];

    edgeList := {};
    for e in E do (
        edgeList = append(edgeList, {R_(e#0), R_(e#1)});
    );

    regularity edgeIdeal graph(edgeList)

);

regularityDegree = (E, L) -> (

    V := #(unique flatten E);

    degs := {};

    for i from 1 to V do (
        if i <= #L then (
            degs = append(degs, 1 + L#(i - 1));
        ) else (
            degs = append(degs, 1);
        );
    );

    R := QQ[x_0..x_(V - 1), Degrees=>degs];

    edgeList := {};
    for e in E do (
        edgeList = append(edgeList, {R_(e#0), R_(e#1)});
    );

    regularity edgeIdeal graph(edgeList)

);

regularityOffset = (E, L) -> (

    regularityCore(E) + sum(L) - regularityDegree(E, L)

);

tropicalFunction = (C) -> (

    inputs -> (

        expressionList := {};

        for term in C do (
            if (#term == 1) then (
                temp := 0;
                for i in term#0 do (
                    temp += inputs#i
                );
                expressionList = append(expressionList, temp)
            ) else (
                temp := 0;
                for i in term#1 do (
                    temp += inputs#i
                );
                expressionList = append(expressionList, temp + term#0)
            );
        );

        min(expressionList)

    )

);

showRegularityOffset = (E, N, L, C) -> (

    V = #(unique flatten E);

    baseRegularity := regularityCore(E);

    resultTable = new MutableHashTable;

    for i from 1 to N do (

        degreeConfigList := {};
        if (#L > 0) then (
            degreeConfigList = createLists(#L, i);
        ) else (
            degreeConfigList = createLists(V, i);
        );

        for degreeConfigPre in degreeConfigList do (

            degreeConfig := {};
            if (#L > 0) then (
                for j from 0 to (V - 1) do (
                    pos := position(L, k->k==j);
                    if (pos === null) then (
                        degreeConfig = append(degreeConfig, 0);
                    ) else (
                        degreeConfig = append(degreeConfig, degreeConfigPre#pos);
                    );
                );
            ) else (
                degreeConfig = degreeConfigPre;
            );
            
            regularityOffsetVar := 0;
            if #C > 0 then (
                inputFunction = tropicalFunction(C);
                regularityOffsetVar = baseRegularity + i - regularityDegree(E, degreeConfig) - inputFunction(degreeConfig);
            ) else (
                regularityOffsetVar = baseRegularity + i - regularityDegree(E, degreeConfig);
            );
            
            if regularityOffsetVar != 0 then (
                if not resultTable#?regularityOffsetVar then resultTable#regularityOffsetVar = {};
                resultTable#regularityOffsetVar = append(resultTable#regularityOffsetVar, degreeConfigPre);
            );

        );

    );

    for num in keys resultTable do (
        for offsetList in resultTable#num do (
            << offsetList << " -> " << num;
            print("");
        );
    );

);

complementEdges = E -> (

    V := #(unique flatten E);

    retList := {};

    for i from 0 to (V - 2) do (
        for j from (i + 1) to (V - 1) do (
            thisEdge := {i, j};
            thisEdgeInverse := {j, i};
            if (not isMember(thisEdge, E)) and (not isMember(thisEdgeInverse, E)) then (
                retList = append(retList, thisEdge)
            );
        );
    );

    retList

);

randomEdges = (V, N) -> (

    R := QQ[x_0..x_(V - 1)];

    isConnected := false;
    count := 0;

    while not isConnected do (

        G := randomGraph(R, N);

        isConnected = isConnectedGraph G;

        count += 1;
        if count >= 14 then (
            return {}
        );

    );

    retList := {};

    for thisEdge in edges G do (
        retList = append(retList, {index thisEdge#0, index thisEdge#1});
    );

    retList

);

resolutionShow = E -> (

    V := #(unique flatten E);

    degList := {};

    for i in 0..(V - 1) do (
        degList = append(degList, toList(insert(i, 1, (V - 1):0)));
    );

    R := QQ[vars(52..(51 + V)), Degrees=>degList];

    edgeList := {};
    for e in E do (
        edgeList = append(edgeList, {R_(e#0), R_(e#1)});
    );

    H := resolution edgeIdeal graph(R, edgeList);

    i := 0;
    while (degree H_i != 0) do (
        print("");
        << "Module[" << i << "] -> " << degree H_i << " | ";
        for j in 0..(degree H_i - 1) do (
            for k in 0..(V - 1) do (
                if (degree H_i_j)#k == 1 then << k;
            );
            << " ";
        );
        print("");
        print("");
        i += 1;
        << "Differential[" << i << "] ->";
        print("");
        print(H.dd_i);
    );

);

offsetGraph = (V, N) -> (

    R := QQ[x_0..x_(V - 1)];

    retIdeals := {};
    retGraphs := {};

    for i from 1 to 100 do (
        E := randomEdges(V, N);
        if (#E > 0) then (
            if (regularityOffset(E, splice {V : 1}) > 0) then (
                edgeList := {};
                for e in E do (
                    edgeList = append(edgeList, {R_(e#0), R_(e#1)});
                );
                isAdd := 1;
                thisEdgeIdeal = edgeIdeal graph(R, edgeList);
                for i in retIdeals do (
                    if (thisEdgeIdeal == i) then (
                        isAdd = 0;
                        break;
                    );
                );
                if (isAdd == 1) then (
                    retIdeals = append(retIdeals, thisEdgeIdeal);
                    retGraphs = append(retGraphs, E);
                );
            ); 
        );
    );

    for g in retGraphs do (
        print(g);
    );

);

Star = L -> (

    ret := {};

    i := 0;
    for limbLength in L do (
        limbVertices = splice {0, (i + 1)..(i + limbLength)};
        for j in 1..limbLength do (
            ret = append(ret, {limbVertices#(j - 1), limbVertices#j});
        );
        i += limbLength;
    );

    << ret;
    print("");
    ret

);

resolutionDegrees = E -> (

    V := #(unique flatten E);

    degList := {};

    for i in 0..(V - 1) do (
        degList = append(degList, toList(insert(i, 1, (V - 1):0)));
    );

    R := QQ[x_0..x_(V - 1), Degrees=>degList];

    edgeList := {};
    for e in E do (
        edgeList = append(edgeList, {R_(e#0), R_(e#1)});
    );
    I = edgeIdeal graph(R, edgeList);

    C := res I;
    l := length C;
    for i in 1..l do (
        << "C_" << i << ": ";
        for j in 0..(degree C_i - 1) do (
            for k in 0..(V - 1) do (
                if (degree C_i_j)#k == 1 then << k;
            );
            << " ";
        );
        print("");
    );

);

resolutionDegreesSimple = E -> (

    V := #(unique flatten E);

    degList := {};

    for i in 0..(V - 1) do (
        degList = append(degList, toList(insert(i, 1, (V - 1):0)));
    );

    R := QQ[x_0..x_(V - 1), Degrees=>degList];

    edgeList := {};
    for e in E do (
        edgeList = append(edgeList, {R_(e#0), R_(e#1)});
    );
    I = edgeIdeal graph(R, edgeList);

    C := res I;
    l := length C;
    for i in 0..l do (
        << "C_" << i << ": " << degree C_i;
        print("");
    );

);

leafGraphMap = E -> (

    V := #(unique flatten E);

    R := QQ[x_0..x_(V - 1), y];

    edgeList := {};
    for e in E do (
        edgeList = append(edgeList, {R_(e#0), R_(e#1)});
    );

    I := edgeIdeal graph(edgeList);

    colonIdeal = I : ideal{x_0*y};

    M := (module R) / colonIdeal;
    N := (module R) / I;

    f := map(N, M, x_0*y);

    print freeResolution f;

);

duoGraphMap = (E1, E2) -> (

    V1 := #(unique flatten E1);
    V2 := #(unique flatten E2);

    R := QQ[x_0..x_(V1 - 1), y_0..y_(V2 - 1)];

    edgeList1 := {};
    for e in E1 do (
        edgeList1 = append(edgeList1, {R_(e#0), R_(e#1)});
    );
    edgeList2 := {};
    for e in E2 do (
        edgeList2 = append(edgeList2, {R_(e#0 + V1), R_(e#1 + V1)});
    );

    I := edgeIdeal graph(edgeList1);
    J := edgeIdeal graph(edgeList2);

    colonIdeal = (I + J) : ideal{x_0*y_0};

    M := (module R) / colonIdeal;
    N := (module R) / (I + J);

    f := map(N, M, x_0*y_0);

    print freeResolution f;

);

TSP = E -> (

    V := #(unique flatten E);

    R := QQ[x_0..x_V];

    I := monomialCurveIdeal(R, E);

    J := I^2;
    K := symbolicPower(I, 2);

    << "Equal in ring: " << (J == K);
    << "\n";

    M := ideal {x_0..x_V};
    RM := R_M; 

    JM := J ** RM;
    KM := K ** RM;

    << "Equal in localization: " << (JM == KM);

);

tg = (A, B) -> (

    L := {};
    for a in A do (
        for b in B do (
            if (a + b != 0) then L = append(L, {a, b});
        );
    );

    M = transpose matrix L;

    print("");
    print(M);
    print("");
    (err, output) := capture("toricGroebner(M)");
    output = replace(" 0", "  ", output);
    print(output);

);

r = E -> regularityCore(E);

ro = (E, L) -> regularityOffset(E, L);

sro = method();
sro (List, ZZ) := (E, N) -> showRegularityOffset(E, N, {}, {});
sro (List, ZZ, List) := (E, N, L) -> showRegularityOffset(E, N, L, {});
sro (List, List, ZZ) := (E, C, N) -> showRegularityOffset(E, N, {}, C);
sro (List, ZZ, List, List) := (E, N, L, C) -> showRegularityOffset(E, N, L, C);

ce = E -> complementEdges(E);

re = (V, N) -> randomEdges(V, N);

rs = E -> resolutionShow(E);

og = method();
og (ZZ, ZZ) := (V, N) -> offsetGraph(V, N);
og (ZZ) := (V) -> (
    for n from (V - 1) to binomial(V, 2) do (
        offsetGraph(V, n);
    );
);

st = L -> Star(L);

rd = E -> resolutionDegrees(E);

rds = E -> resolutionDegreesSimple(E);

saved = {
    {
        {0, 1},
        {1 ,2},
        {1, 3},
        {1, 4},
        {1, 5},
        {1, 6},
        {2, 3},
        {3, 5},
        {5, 6},
        {6, 4},
        {4, 2},
        {5, 7},
        {6, 7}
    }
};

print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("     ____  ____   _____  _____   ____  _____    _____      _____  ");
print("    |_  _||_  _| |_   _||_   _| |_   \\|_   _|  |_   _|    |_   _| ");
print("      \\ \\  / /     | |    | |     |   \\\\| |      | |        | |   ");
print("       \\ \\/ /      | '    ' |     | |\\ \\| |      | |   _    | |   ");
print("       _|  |_       \\ \\__/ /     _| |_\\   |_    _| |__/ |  _| |_  ");
print("      |______|       `.__.'     |_____|\\____|  |________| |_____| ");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
print("");
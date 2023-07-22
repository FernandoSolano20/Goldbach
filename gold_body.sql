CREATE OR REPLACE PACKAGE BODY gold IS

  FUNCTION IsPrime(n NUMBER) RETURN BOOLEAN IS
    factorial number := 0;
    counter number := 0;
  BEGIN
    FOR i IN 1..n LOOP
      IF MOD(n, i) = 0 THEN
        counter := counter + 1;
      END IF;
    END LOOP;
    RETURN counter = 2;
  END IsPrime;

  FUNCTION Goldbach(n NUMBER) RETURN nPrime IS
    numbers nPrime := nPrime(0,0,0);
    counter number := 0;
    CURSOR prime_cursor1 IS 
    SELECT valor
    FROM PRIME
    WHERE valor <= n;
    CURSOR prime_cursor2 IS 
    SELECT valor
    FROM PRIME
    WHERE valor <= n;
  BEGIN
    IF MOD(n, 2) <> 0 THEN
      numbers.n1 := NULL;
      numbers.n2 := NULL;
      numbers.i := NULL;
      RETURN numbers;
    END IF;

    FOR prime_record1 IN prime_cursor1 LOOP
      FOR prime_record2 IN prime_cursor2 LOOP
        counter := counter + 1;
        IF prime_record1.valor + prime_record2.valor = n THEN
          numbers.n1 := prime_record1.valor;
          numbers.n2 := prime_record2.valor;
          numbers.i := counter;
          RETURN numbers;
        END IF;
      END LOOP;
    END LOOP;

    numbers.n1 := 0;
    numbers.n2 := 0;
    numbers.i := counter;  
    RETURN numbers;
  END Goldbach;

  PROCEDURE SetPrime(n NUMBER) IS
    CURSOR max_prime_cursor IS
    SELECT MAX(valor) FROM PRIME;
    last_prime PRIME.valor%TYPE := NULL;
    counter NUMBER := 0;
    insert_two_and_three_number EXCEPTION;
    no_numbers_to_insert EXCEPTION;
  BEGIN
    OPEN max_prime_cursor;
    FETCH max_prime_cursor INTO last_prime;
    CLOSE max_prime_cursor;

    BEGIN
      IF last_prime IS NULL THEN
        FOR i IN 2..3 LOOP
          INSERT INTO PRIME VALUES (i);
          counter := counter + 1;
        END LOOP;
        COMMIT;
        last_prime := 3;
        RAISE insert_two_and_three_number;
      END IF;
      EXCEPTION
        WHEN insert_two_and_three_number THEN
          DBMS_OUTPUT.PUT_LINE('El sistema debe insertar los numeros 2 y 3');
    END;
    
    BEGIN
      IF n <= last_prime THEN
        RAISE no_numbers_to_insert;
      ELSE 
        FOR i IN last_prime + 1..n LOOP
          IF IsPrime(i) THEN
            INSERT INTO PRIME VALUES (i);
            counter := counter + 1;
          END IF;
        END LOOP;
        IF counter = 0 THEN
          RAISE no_numbers_to_insert;
        END IF;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Se han insertado ' || counter || ' numeros primos');
      END IF;
      EXCEPTION
        WHEN no_numbers_to_insert THEN
          DBMS_OUTPUT.PUT_LINE('No hay primos que agregar');
    END;
  END SetPrime;

  PROCEDURE Test(n NUMBER) IS
    position NUMBER := 0;
    counter NUMBER := 0;
    division NUMBER := 0;
    nums nPrime := nPrime(0,0,0);
  BEGIN
    IF IsPrime(n) THEN
      SELECT position INTO position
      FROM (SELECT ROWNUM position, valor
            FROM PRIME)
      WHERE valor = n;
      DBMS_OUTPUT.PUT_LINE(n || ' es primo. Posicion: ' || position);
    ELSIF MOD(n, 2) <> 0 THEN
      FOR i IN 2..n-1 LOOP
        IF MOD(n, i) = 0 THEN
          division := n / i;
          DBMS_OUTPUT.PUT_LINE(n ||' es impar. Multiples: ' || i || '*' || division);
          EXIT;
        END IF;
        counter := counter + 1;
      END LOOP;
    ELSE
      nums := Goldbach(n);
      DBMS_OUTPUT.PUT_LINE(n ||' es par. Primos: ' || nums.n1 || '+' || nums.n2 || '. Iteraciones: ' || nums.i);
    END IF;
    EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('El numero primo no esta en la tabla prime de primos, agregue mas primos a la tabla');
  END Test;
END gold;
/
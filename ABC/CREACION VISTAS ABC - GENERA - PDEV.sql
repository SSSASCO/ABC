--[GENERAL]--------------------------------------------------------------------------------

CREATE VIEW ClasificacionABCprecios AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO    
FROM 
    INVENTARIO_MOVIMIENTOS 
    JOIN REFERENCIAS ON (REFERENCIAS.REFERENCIA = INVENTARIO_MOVIMIENTOS.REFERENCIA)
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV0', 'PdeV1') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' AND REFERENCIAS.Servicio ='0' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankprecios AS 
SELECT 
	ClasificacionABCprecios.*,
	RANK() OVER (ORDER BY ClasificacionABCprecios.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCprecios.PRECIO) OVER (ORDER BY ClasificacionABCprecios.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCprecios


CREATE VIEW ClasificacionABCMovimientos AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
JOIN REFERENCIAS ON (REFERENCIAS.REFERENCIA = INVENTARIO_MOVIMIENTOS.REFERENCIA)
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV0', 'PdeV1') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' AND REFERENCIAS.Servicio ='0' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankMovimientos AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientos.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientos.cantidad) OVER (ORDER BY ClasificacionABCMovimientos.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientos


CREATE VIEW Clasificacion_Final_ABC_Precios AS
SELECT 
	ClasificacionABCRankprecios.*,
   IIF(
        ClasificacionABCRankprecios.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCprecios.precio) * 0.8,0) FROM ClasificacionABCprecios), 
        'A', 
        IIF(
            ClasificacionABCRankprecios.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCprecios.precio) * 0.95,0) FROM ClasificacionABCprecios), 
            'B', 
            IIF(
                ClasificacionABCRankprecios.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCprecios.precio) * 1,0) FROM ClasificacionABCprecios), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankprecios


CREATE VIEW Clasificacion_Final_ABC_Movimientos AS
SELECT 
	ClasificacionABCRankMovimientos.*,
IIF(ClasificacionABCRankMovimientos.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientos.cantidad) * 0.8,0) FROM ClasificacionABCMovimientos), 
    'A', 
    IIF(ClasificacionABCRankMovimientos.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientos.cantidad) * 0.95,0) FROM ClasificacionABCMovimientos), 
        'M', 
        IIF(ClasificacionABCRankMovimientos.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientos.cantidad) * 1,0) FROM ClasificacionABCMovimientos), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientos



--[PdeV0]--------------------------------------------------------------------------------

CREATE VIEW ClasificacionABCpreciosPdeV0 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV0') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV0 AS 
SELECT 
	ClasificacionABCpreciosPdeV0.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV0.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV0.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV0.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV0

CREATE VIEW ClasificacionABCMovimientosPdeV0 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV0') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV0 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV0.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV0.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV0.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV0

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV0 AS
SELECT 
	ClasificacionABCRankpreciosPdeV0.*,
   IIF(
        ClasificacionABCRankpreciosPdeV0.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV0.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV0), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV0.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV0.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV0), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV0.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV0.precio) * 1,0) FROM ClasificacionABCpreciosPdeV0), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV0    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV0 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV0.*,
IIF(ClasificacionABCRankMovimientosPdeV0.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV0.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV0), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV0.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV0.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV0), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV0.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV0.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV0), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV0    


--[PdeV1]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV1 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV1') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV1 AS 
SELECT 
	ClasificacionABCpreciosPdeV1.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV1.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV1.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV1.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV1

CREATE VIEW ClasificacionABCMovimientosPdeV1 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV1') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV1 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV1.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV1.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV1.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV1

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV1 AS
SELECT 
	ClasificacionABCRankpreciosPdeV1.*,
   IIF(
        ClasificacionABCRankpreciosPdeV1.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV1.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV1), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV1.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV1.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV1), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV1.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV1.precio) * 1,0) FROM ClasificacionABCpreciosPdeV1), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV1    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV1 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV1.*,
IIF(ClasificacionABCRankMovimientosPdeV1.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV1.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV1), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV1.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV1.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV1), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV1.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV1.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV1), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV1    


--[PdeV2]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV2 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV2') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV2 AS 
SELECT 
	ClasificacionABCpreciosPdeV2.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV2.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV2.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV2.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV2

CREATE VIEW ClasificacionABCMovimientosPdeV2 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV2') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV2 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV2.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV2.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV2.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV2

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV2 AS
SELECT 
	ClasificacionABCRankpreciosPdeV2.*,
   IIF(
        ClasificacionABCRankpreciosPdeV2.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV2.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV2), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV2.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV2.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV2), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV2.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV2.precio) * 1,0) FROM ClasificacionABCpreciosPdeV2), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV2    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV2 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV2.*,
IIF(ClasificacionABCRankMovimientosPdeV2.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV2.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV2), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV2.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV2.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV2), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV2.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV2.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV2), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV2    


--[PdeV3]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV3 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV3') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV3 AS 
SELECT 
	ClasificacionABCpreciosPdeV3.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV3.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV3.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV3.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV3

CREATE VIEW ClasificacionABCMovimientosPdeV3 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV3') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV3 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV3.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV3.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV3.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV3

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV3 AS
SELECT 
	ClasificacionABCRankpreciosPdeV3.*,
   IIF(
        ClasificacionABCRankpreciosPdeV3.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV3.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV3), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV3.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV3.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV3), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV3.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV3.precio) * 1,0) FROM ClasificacionABCpreciosPdeV3), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV3    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV3 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV3.*,
IIF(ClasificacionABCRankMovimientosPdeV3.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV3.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV3), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV3.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV3.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV3), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV3.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV3.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV3), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV3    


--[PdeV4]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV4 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV4') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV4 AS 
SELECT 
	ClasificacionABCpreciosPdeV4.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV4.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV4.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV4.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV4

CREATE VIEW ClasificacionABCMovimientosPdeV4 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV4') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV4 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV4.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV4.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV4.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV4

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV4 AS
SELECT 
	ClasificacionABCRankpreciosPdeV4.*,
   IIF(
        ClasificacionABCRankpreciosPdeV4.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV4.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV4), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV4.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV4.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV4), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV4.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV4.precio) * 1,0) FROM ClasificacionABCpreciosPdeV4), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV4    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV4 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV4.*,
IIF(ClasificacionABCRankMovimientosPdeV4.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV4.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV4), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV4.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV4.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV4), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV4.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV4.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV4), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV4    


--[PdeV5]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV5 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV5') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV5 AS 
SELECT 
	ClasificacionABCpreciosPdeV5.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV5.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV5.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV5.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV5

CREATE VIEW ClasificacionABCMovimientosPdeV5 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV5') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV5 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV5.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV5.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV5.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV5

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV5 AS
SELECT 
	ClasificacionABCRankpreciosPdeV5.*,
   IIF(
        ClasificacionABCRankpreciosPdeV5.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV5.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV5), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV5.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV5.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV5), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV5.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV5.precio) * 1,0) FROM ClasificacionABCpreciosPdeV5), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV5    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV5 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV5.*,
IIF(ClasificacionABCRankMovimientosPdeV5.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV5.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV5), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV5.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV5.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV5), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV5.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV5.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV5), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV5    


--[PdeV6]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV6 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV6') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV6 AS 
SELECT 
	ClasificacionABCpreciosPdeV6.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV6.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV6.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV6.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV6

CREATE VIEW ClasificacionABCMovimientosPdeV6 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV6') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV6 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV6.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV6.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV6.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV6

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV6 AS
SELECT 
	ClasificacionABCRankpreciosPdeV6.*,
   IIF(
        ClasificacionABCRankpreciosPdeV6.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV6.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV6), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV6.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV6.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV6), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV6.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV6.precio) * 1,0) FROM ClasificacionABCpreciosPdeV6), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV6    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV6 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV6.*,
IIF(ClasificacionABCRankMovimientosPdeV6.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV6.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV6), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV6.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV6.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV6), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV6.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV6.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV6), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV6    


--[PdeV7]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV7 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV7') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV7 AS 
SELECT 
	ClasificacionABCpreciosPdeV7.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV7.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV7.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV7.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV7

CREATE VIEW ClasificacionABCMovimientosPdeV7 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV7') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV7 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV7.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV7.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV7.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV7

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV7 AS
SELECT 
	ClasificacionABCRankpreciosPdeV7.*,
   IIF(
        ClasificacionABCRankpreciosPdeV7.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV7.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV7), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV7.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV7.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV7), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV7.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV7.precio) * 1,0) FROM ClasificacionABCpreciosPdeV7), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV7    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV7 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV7.*,
IIF(ClasificacionABCRankMovimientosPdeV7.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV7.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV7), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV7.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV7.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV7), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV7.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV7.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV7), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV7    


--[PdeV8]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV8 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV8') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV8 AS 
SELECT 
	ClasificacionABCpreciosPdeV8.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV8.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV8.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV8.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV8

CREATE VIEW ClasificacionABCMovimientosPdeV8 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV8') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV8 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV8.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV8.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV8.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV8

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV8 AS
SELECT 
	ClasificacionABCRankpreciosPdeV8.*,
   IIF(
        ClasificacionABCRankpreciosPdeV8.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV8.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV8), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV8.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV8.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV8), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV8.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV8.precio) * 1,0) FROM ClasificacionABCpreciosPdeV8), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV8    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV8 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV8.*,
IIF(ClasificacionABCRankMovimientosPdeV8.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV8.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV8), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV8.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV8.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV8), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV8.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV8.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV8), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV8    

--[PdeV9]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV9 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV9') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV9 AS 
SELECT 
	ClasificacionABCpreciosPdeV9.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV9.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV9.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV9.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV9

CREATE VIEW ClasificacionABCMovimientosPdeV9 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV9') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV9 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV9.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV9.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV9.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV9

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV9 AS
SELECT 
	ClasificacionABCRankpreciosPdeV9.*,
   IIF(
        ClasificacionABCRankpreciosPdeV9.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV9.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV9), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV9.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV9.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV9), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV9.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV9.precio) * 1,0) FROM ClasificacionABCpreciosPdeV9), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV9    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV9 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV9.*,
IIF(ClasificacionABCRankMovimientosPdeV9.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV9.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV9), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV9.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV9.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV9), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV9.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV9.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV9), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV9    


--[PdeV10]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV10 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV10') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV10 AS 
SELECT 
	ClasificacionABCpreciosPdeV10.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV10.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV10.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV10.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV10

CREATE VIEW ClasificacionABCMovimientosPdeV10 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV10') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV10 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV10.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV10.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV10.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV10

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV10 AS
SELECT 
	ClasificacionABCRankpreciosPdeV10.*,
   IIF(
        ClasificacionABCRankpreciosPdeV10.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV10.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV10), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV10.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV10.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV10), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV10.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV10.precio) * 1,0) FROM ClasificacionABCpreciosPdeV10), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV10    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV10 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV10.*,
IIF(ClasificacionABCRankMovimientosPdeV10.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV10.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV10), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV10.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV10.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV10), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV10.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV10.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV10), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV10    


--[PdeV11]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV11 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV11') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV11 AS 
SELECT 
	ClasificacionABCpreciosPdeV11.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV11.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV11.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV11.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV11

CREATE VIEW ClasificacionABCMovimientosPdeV11 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV11') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV11 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV11.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV11.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV11.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV11

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV11 AS
SELECT 
	ClasificacionABCRankpreciosPdeV11.*,
   IIF(
        ClasificacionABCRankpreciosPdeV11.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV11.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV11), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV11.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV11.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV11), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV11.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV11.precio) * 1,0) FROM ClasificacionABCpreciosPdeV11), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV11    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV11 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV11.*,
IIF(ClasificacionABCRankMovimientosPdeV11.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV11.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV11), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV11.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV11.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV11), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV11.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV11.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV11), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV11    


--[PdeV12]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV12 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV12') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV12 AS 
SELECT 
	ClasificacionABCpreciosPdeV12.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV12.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV12.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV12.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV12

CREATE VIEW ClasificacionABCMovimientosPdeV12 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV12') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV12 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV12.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV12.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV12.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV12

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV12 AS
SELECT 
	ClasificacionABCRankpreciosPdeV12.*,
   IIF(
        ClasificacionABCRankpreciosPdeV12.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV12.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV12), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV12.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV12.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV12), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV12.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV12.precio) * 1,0) FROM ClasificacionABCpreciosPdeV12), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV12    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV12 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV12.*,
IIF(ClasificacionABCRankMovimientosPdeV12.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV12.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV12), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV12.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV12.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV12), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV12.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV12.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV12), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV12    


--[PdeV13]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV13 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV13') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV13 AS 
SELECT 
	ClasificacionABCpreciosPdeV13.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV13.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV13.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV13.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV13

CREATE VIEW ClasificacionABCMovimientosPdeV13 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV13') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV13 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV13.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV13.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV13.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV13

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV13 AS
SELECT 
	ClasificacionABCRankpreciosPdeV13.*,
   IIF(
        ClasificacionABCRankpreciosPdeV13.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV13.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV13), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV13.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV13.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV13), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV13.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV13.precio) * 1,0) FROM ClasificacionABCpreciosPdeV13), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV13    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV13 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV13.*,
IIF(ClasificacionABCRankMovimientosPdeV13.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV13.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV13), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV13.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV13.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV13), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV13.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV13.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV13), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV13    


--[PdeV14]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV14 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV14') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV14 AS 
SELECT 
	ClasificacionABCpreciosPdeV14.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV14.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV14.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV14.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV14

CREATE VIEW ClasificacionABCMovimientosPdeV14 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV14') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV14 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV14.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV14.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV14.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV14

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV14 AS
SELECT 
	ClasificacionABCRankpreciosPdeV14.*,
   IIF(
        ClasificacionABCRankpreciosPdeV14.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV14.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV14), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV14.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV14.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV14), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV14.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV14.precio) * 1,0) FROM ClasificacionABCpreciosPdeV14), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV14    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV14 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV14.*,
IIF(ClasificacionABCRankMovimientosPdeV14.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV14.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV14), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV14.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV14.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV14), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV14.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV14.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV14), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV14    


--[PdeV15]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV15 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV15') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV15 AS 
SELECT 
	ClasificacionABCpreciosPdeV15.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV15.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV15.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV15.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV15

CREATE VIEW ClasificacionABCMovimientosPdeV15 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV15') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV15 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV15.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV15.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV15.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV15

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV15 AS
SELECT 
	ClasificacionABCRankpreciosPdeV15.*,
   IIF(
        ClasificacionABCRankpreciosPdeV15.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV15.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV15), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV15.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV15.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV15), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV15.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV15.precio) * 1,0) FROM ClasificacionABCpreciosPdeV15), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV15    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV15 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV15.*,
IIF(ClasificacionABCRankMovimientosPdeV15.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV15.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV15), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV15.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV15.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV15), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV15.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV15.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV15), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV15    

--[PdeV16]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV16 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV16') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV16 AS 
SELECT 
	ClasificacionABCpreciosPdeV16.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV16.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV16.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV16.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV16

CREATE VIEW ClasificacionABCMovimientosPdeV16 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV16') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV16 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV16.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV16.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV16.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV16

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV16 AS
SELECT 
	ClasificacionABCRankpreciosPdeV16.*,
   IIF(
        ClasificacionABCRankpreciosPdeV16.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV16.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV16), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV16.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV16.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV16), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV16.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV16.precio) * 1,0) FROM ClasificacionABCpreciosPdeV16), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV16    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV16 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV16.*,
IIF(ClasificacionABCRankMovimientosPdeV16.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV16.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV16), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV16.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV16.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV16), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV16.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV16.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV16), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV16    


--[PdeV17]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV17 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV17') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV17 AS 
SELECT 
	ClasificacionABCpreciosPdeV17.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV17.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV17.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV17.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV17

CREATE VIEW ClasificacionABCMovimientosPdeV17 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV17') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV17 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV17.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV17.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV17.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV17

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV17 AS
SELECT 
	ClasificacionABCRankpreciosPdeV17.*,
   IIF(
        ClasificacionABCRankpreciosPdeV17.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV17.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV17), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV17.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV17.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV17), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV17.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV17.precio) * 1,0) FROM ClasificacionABCpreciosPdeV17), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV17    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV17 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV17.*,
IIF(ClasificacionABCRankMovimientosPdeV17.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV17.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV17), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV17.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV17.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV17), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV17.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV17.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV17), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV17    


--[PdeV18]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV18 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV18') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV18 AS 
SELECT 
	ClasificacionABCpreciosPdeV18.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV18.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV18.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV18.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV18

CREATE VIEW ClasificacionABCMovimientosPdeV18 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV18') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV18 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV18.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV18.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV18.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV18

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV18 AS
SELECT 
	ClasificacionABCRankpreciosPdeV18.*,
   IIF(
        ClasificacionABCRankpreciosPdeV18.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV18.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV18), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV18.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV18.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV18), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV18.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV18.precio) * 1,0) FROM ClasificacionABCpreciosPdeV18), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV18    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV18 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV18.*,
IIF(ClasificacionABCRankMovimientosPdeV18.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV18.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV18), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV18.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV18.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV18), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV18.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV18.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV18), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV18    


--[PdeV19]--------------------------------------------------------------------------------

SELECT STRING_AGG(CONCAT('''',ID,''''),',') FROM PUNTO_VENTA WHERE ENABLED ='1'


CREATE VIEW ClasificacionABCpreciosPdeV19 AS 
SELECT 
    INVENTARIO_MOVIMIENTOS.REFERENCIA, 
    SUM(INVENTARIO_MOVIMIENTOS.Cantidad * INVENTARIO_MOVIMIENTOS.PrecioVenta) AS PRECIO
FROM 
    INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV19') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia


CREATE VIEW ClasificacionABCRankpreciosPdeV19 AS 
SELECT 
	ClasificacionABCpreciosPdeV19.*,
	RANK() OVER (ORDER BY ClasificacionABCpreciosPdeV19.PRECIO DESC) AS Ranking,
	SUM(ClasificacionABCpreciosPdeV19.PRECIO) OVER (ORDER BY ClasificacionABCpreciosPdeV19.PRECIO DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCpreciosPdeV19

CREATE VIEW ClasificacionABCMovimientosPdeV19 AS 
SELECT INVENTARIO_MOVIMIENTOS.REFERENCIA, 
SUM(INVENTARIO_MOVIMIENTOS.Cantidad) AS CANTIDAD
FROM INVENTARIO_MOVIMIENTOS 
WHERE INVENTARIO_MOVIMIENTOS.Fecha BETWEEN DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(MONTH, -3, GETDATE())) + 1, 0)) AND DATEADD(day, -1, DATEADD(DAY, DATEDIFF(DAY, 0, GETDATE()) + 1, 0)) AND ID_PuntoVenta IN ('PdeV19') AND INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA POS' OR INVENTARIO_MOVIMIENTOS.Movimiento = 'FACTURA INSTITUCIONAL' GROUP BY INVENTARIO_MOVIMIENTOS.Referencia    

CREATE VIEW ClasificacionABCRankMovimientosPdeV19 AS 
SELECT 
	*,
	RANK() OVER (ORDER BY ClasificacionABCMovimientosPdeV19.cantidad DESC) AS Ranking,
SUM(ClasificacionABCMovimientosPdeV19.cantidad) OVER (ORDER BY ClasificacionABCMovimientosPdeV19.cantidad DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumulado
FROM
	ClasificacionABCMovimientosPdeV19

CREATE VIEW Clasificacion_Final_ABC_PreciosPdeV19 AS
SELECT 
	ClasificacionABCRankpreciosPdeV19.*,
   IIF(
        ClasificacionABCRankpreciosPdeV19.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCpreciosPdeV19.precio) * 0.8,0) FROM ClasificacionABCpreciosPdeV19), 
        'A', 
        IIF(
            ClasificacionABCRankpreciosPdeV19.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV19.precio) * 0.95,0) FROM ClasificacionABCpreciosPdeV19), 
            'B', 
            IIF(
                ClasificacionABCRankpreciosPdeV19.TotalAcumulado <= (SELECT round ( SUM(ClasificacionABCpreciosPdeV19.precio) * 1,0) FROM ClasificacionABCpreciosPdeV19), 
                'C', 
                'D'
            )
        )
    ) AS Clasificacion
FROM 
	ClasificacionABCRankpreciosPdeV19    


CREATE VIEW Clasificacion_Final_ABC_MovimientosPdeV19 AS
SELECT 
	ClasificacionABCRankMovimientosPdeV19.*,
IIF(ClasificacionABCRankMovimientosPdeV19.TotalAcumulado < (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV19.cantidad) * 0.8,0) FROM ClasificacionABCMovimientosPdeV19), 
    'A', 
    IIF(ClasificacionABCRankMovimientosPdeV19.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV19.cantidad) * 0.95,0) FROM ClasificacionABCMovimientosPdeV19), 
        'M', 
        IIF(ClasificacionABCRankMovimientosPdeV19.TotalAcumulado <= (SELECT ROUND(SUM(ClasificacionABCMovimientosPdeV19.cantidad) * 1,0) FROM ClasificacionABCMovimientosPdeV19), 
            'B', 
            'D'
        )
    )
) AS Clasificacion
FROM 
	ClasificacionABCRankMovimientosPdeV19    





















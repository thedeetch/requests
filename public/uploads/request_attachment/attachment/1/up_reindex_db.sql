USE [PCM_Maintenance]
GO
/****** Object:  StoredProcedure [dbo].[up_reindex_db]    Script Date: 07/11/2013 8:18:00 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/*********************************************************************************
* Purpose:  This script will reindex all indexes on one or many databases on a   *
*			given server.														 *
*																				 *
*	PARAMETERS:																	 *
*		@db_nm - Name of database.  Passing in 'ALL' will iterate through all	 *
*					databases.													 *
*		@maxdop - Max degree of parallelism option to limit the number of		 *
*					processors to use in parallel plan execution				 *
*		@dbcc_chk - Checks the logical and physical integrity of all the objects * 
*					in the specified database									 *
*		@onln - Specifies whether underlying tables and associated indexes are	 *
*					available for queries and data modification during the index * 
*					operation													 *
**********************************************************************************
 Performance Statistics														 
**********************************************************************************
 Date ran: 05/09/2012															 
 Statement ran: up_reindex_db 'ALL'												 
 Run time in seconds: SQL047 - 3m23s
  Statement ran: up_reindex_db 'IP'												 
 Run time in seconds: SQL055 - 51s													 
********************************************************************************** 
 Maintenance Log 
**********************************************************************************
 03/16/2012 Version #: 1.00 Chg Mgmt #: 259240  Joe Fiderlick
    Desc: Initial creation.
 04/24/2012 Version #: 1.01 Chg Mgmt #: 261789  Joe Fiderlick
    Desc: -Swapped direct code for up_dbcc_checkdb use.  
          -Included statistics update for all tables regardless of fragmentation			
*********************************************************************************/

ALTER PROCEDURE [dbo].[up_reindex_db]
    @db_nm VARCHAR(128) ,
    @maxdop INT = 0 ,
    @dbcc_chk BIT = 0 ,
    @onln BIT = 0
AS 
    BEGIN
        DECLARE @db_id INTEGER ,
            @db_nm_var VARCHAR(128) ,
            @obj_id INTEGER ,
            @dbcc_chk_flg BIT ,
            @indx_id INTEGER ,
            @prtn_cnt BIGINT ,
            @schm_nm SYSNAME ,
            @obj_nm SYSNAME ,
            @indx_nm SYSNAME ,
            @indx_typ_nm TINYINT ,
            @prtn_nmbr BIGINT ,
            @prtns BIGINT ,
            @frag FLOAT ,
            @fill_fctr INTEGER ,
            @data_cmprs_opt_txt VARCHAR(15) ,
            @cmd_txt NVARCHAR(MAX) ,
            @dbcc_fail_lst VARCHAR(MAX) ,
            @sql_err_cd INT ,
            @dbcc_err_flg BIT ,
            @sql_err_msg VARCHAR(MAX) ,
            @dbcc_txt NVARCHAR(1000) ,
            @beg_tm DATETIME ,
            @id INTEGER ,
            @btch_tm DATETIME

        SET NOCOUNT ON
  
        SET @btch_tm = GETDATE()

        IF @onln NOT IN ( 0, 1 ) 
            RAISERROR (N'Invalid value for parameter @onln.  Specify Y to perform online index operations where possible, N for offline operations.'
				,16
				,1) 
				
	--Ensure that cursors are closed and deallocated prior to execution
        IF ( SELECT CURSOR_STATUS('global', 'db_curs')
           ) >= 0 
            BEGIN
                CLOSE db_curs
                DEALLOCATE db_curs
            END
	  
        IF ( SELECT CURSOR_STATUS('global', 'prtn_curs')
           ) >= 0 
            BEGIN
                CLOSE prtn_curs
                DEALLOCATE prtn_curs
            END

    /*******************************************************************************/
	/*                             CREATE TABLES                                   */
	/*******************************************************************************/
        IF OBJECT_ID('tempdb..#onln_op') IS NOT NULL 
            DROP TABLE #onln_op

        CREATE TABLE [#onln_op] ( is_onln VARCHAR(3) )
        INSERT  INTO #onln_op
        VALUES  ( 'ON' )
	
        IF OBJECT_ID('tempdb..#work_to_do') IS NOT NULL 
            DROP TABLE #work_to_do

        CREATE TABLE [#work_to_do]
            (
              [dbid] INTEGER NULL ,
              dbname VARCHAR(250) ,
              schemaname VARCHAR(250) ,
              objectid INTEGER NULL ,
              objectname VARCHAR(250) ,
              indexid INTEGER NULL ,
              indexname VARCHAR(250) ,
              indextype TINYINT ,
              partitionnum INTEGER NULL ,
              frag FLOAT NULL ,
              [fillfactor] INTEGER
       --data_cmprs_opt VARCHAR(15)
            )

	/*******************************************************************************/
	/*                             END CREATE TABLES                               */
	/*******************************************************************************/

        IF @db_nm = 'ALL' 
            BEGIN
                DECLARE db_curs CURSOR FAST_FORWARD
                FOR
                    SELECT  d.database_id ,
                            d.name ,
                            db_stat_info.dbcc_chk_flg
                    FROM    sys.databases d
                            INNER JOIN db_stat_info ON UPPER(d.name) = UPPER(db_stat_info.db_nm)
                    WHERE   d.name <> 'tempdb'
                            AND d.state = 0
                            AND d.is_read_only = 0
                            AND db_stat_info.reindex_flg = 1
            END
        ELSE 
            BEGIN
                DECLARE db_curs CURSOR FAST_FORWARD
                FOR
                    SELECT  d.database_id ,
                            d.name ,
                            db_stat_info.dbcc_chk_flg
                    FROM    sys.databases d
                            INNER JOIN db_stat_info ON UPPER(d.name) = UPPER(db_stat_info.db_nm)
                    WHERE   d.name <> 'tempdb'
                            AND d.state = 0
                            AND d.is_read_only = 0
                            AND d.name = @db_nm
            END

        OPEN db_curs
        FETCH NEXT FROM db_curs INTO @db_id, @db_nm_var, @dbcc_chk_flg

        WHILE @@FETCH_STATUS = 0 
            BEGIN

                PRINT CONVERT(VARCHAR, GETDATE(), 120)
                    + '  Beginning index maintenance for database: '
                    + @db_nm_var

                SET @cmd_txt = 'USE ' + QUOTENAME(@db_nm_var, '[') + '
			INSERT INTO #work_to_do
			SELECT
				' + CAST(@db_id AS VARCHAR(2000)) + ' as dbid,
				''' + @db_nm_var + ''',
				sch.name,
				s.object_id AS objectid,
				o.name,
				s.index_id AS indexid,
				i.name,
				i.type,
				s.partition_number AS partitionnum,
				s.avg_fragmentation_in_percent AS frag,
				i.fill_factor
				--''NONE'' AS data_cmprs_opt
			FROM sys.dm_db_index_physical_stats ('
                    + CAST(@db_id AS VARCHAR(2000))
                    + ', NULL, NULL , NULL, ''LIMITED'') s
			INNER JOIN sys.objects o (NOLOCK) 
				ON o.object_id = s.object_id
			INNER JOIN sys.indexes i (NOLOCK) 
				ON i.object_id = s.object_id and i.index_id = s.index_id
			INNER JOIN sys.schemas sch (NOLOCK) 
				ON sch.schema_id = o.schema_id
			WHERE s.index_id > 0
			'

                EXEC sp_executesql @cmd_txt
        
        --Update fragmentation percentage for indexes where page locks are not allowed to force index rebuild.
                SET @cmd_txt = 'USE ' + QUOTENAME(@db_nm_var, '[') + '
			UPDATE #work_to_do
			SET frag = 999
			FROM #work_to_do w
			INNER JOIN sys.indexes i
			  ON i.object_id = w.objectid
			    AND i.index_id = w.indexid
			WHERE i.allow_page_locks = 0
			'

                EXEC sp_executesql @cmd_txt
        
        --Update PAGE/ROW compression column to include in ALTER INDEX statement if applicable.
  --      IF LEFT(CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(128)), 1) <> '9' 
  --      BEGIN
  --        SET @cmd_txt = 'USE ' + QUOTENAME(@db_nm_var, '[') + '
		--	              UPDATE #work_to_do
		--	              SET data_cmprs_opt = sp.data_compression_desc
		--	              FROM sys.partitions sp
		--	              INNER JOIN sys.objects obj
		--					ON sp.object_id = obj.object_id
		--			      INNER JOIN sys.indexes idx
		--			        ON idx.object_id = sp.object_id
		--			          AND idx.index_id = sp.index_id
		--			      INNER JOIN #work_to_do wtd
		--			        ON obj.object_id = wtd.objectid
		--			          AND idx.index_id = wtd.indexid
		--			      WHERE data_compression <> 0
		--	  '

  --        EXEC sp_executesql @cmd_txt
		--END 

        --TESTING LINE	
		--SELECT * FROM #work_to_do

		-- Open the cursor.
                DECLARE prtn_curs CURSOR FAST_FORWARD
                FOR
                    SELECT  *
                    FROM    #work_to_do
                    ORDER BY frag DESC 

                OPEN prtn_curs 
                FETCH NEXT FROM prtn_curs
			   INTO @db_id, @db_nm_var, @schm_nm, @obj_id, @obj_nm, @indx_id,
                    @indx_nm, @indx_typ_nm, @prtn_nmbr, @frag, @fill_fctr--, @data_cmprs_opt_txt

                WHILE @@FETCH_STATUS = 0 
                    BEGIN
			--If offline, do not check for forbidden datatypes
                        IF @onln = 0 
                            UPDATE  #onln_op
                            SET     is_onln = 'OFF'
                        ELSE 
                            BEGIN
				--Start by assuming an online operation
                                UPDATE  #onln_op
                                SET     is_onln = 'ON'

				--Clustered check all columns for forbidden datatypes
                                IF @indx_typ_nm = 1 
                                    BEGIN
                                        SET @cmd_txt = 'UPDATE #onln_op SET is_onln = ''OFF'' WHERE EXISTS(SELECT 1 FROM '
                                            + QUOTENAME(@db_nm_var, '[')
                                            + '.sys.columns c
							INNER JOIN ' + QUOTENAME(@db_nm_var, '[')
                                            + '.sys.types t 
								ON c.system_type_id = t.user_type_id OR (c.user_type_id = t.user_type_id AND t.is_assembly_type = 1)
							WHERE c.[object_id] = '
                                            + CAST(@obj_id AS VARCHAR(50))
                                            + '
								AND (t.name IN(''xml'',''image'',''text'',''ntext'')
								OR (t.name IN(''varchar'',''nvarchar'',''varbinary'') AND (c.max_length = t.max_length or c.max_length = -1))
								OR (t.is_assembly_type = 1 AND c.max_length = -1)))'
                                        EXEC sp_executesql @cmd_txt
                                    END

				--NonClustered check just the index columns for forbidden datatypes
                                IF @indx_typ_nm = 2 
                                    BEGIN
                                        SET @cmd_txt = 'UPDATE #onln_op SET is_onln = ''OFF'' WHERE EXISTS(SELECT 1 FROM '
                                            + QUOTENAME(@db_nm_var, '[')
                                            + '.sys.indexes i
							INNER JOIN ' + QUOTENAME(@db_nm_var, '[')
                                            + '.sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
							INNER JOIN ' + QUOTENAME(@db_nm_var, '[')
                                            + '.sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
							INNER JOIN ' + QUOTENAME(@db_nm_var, '[')
                                            + '.sys.types t ON c.user_type_id = t.user_type_id
							WHERE (
									t.name IN (''text'', ''ntext'', ''image'', ''xml'')
									OR (t.name in (''varchar'', ''nvarchar'', ''varbinary'') AND c.max_length = t.max_length OR c.max_length = -1)
									OR (t.is_assembly_type = 1 AND c.max_length = -1)
								  )
							AND i.object_id = ' + CAST(@obj_id AS VARCHAR(50))
                                            + '
							AND i.index_id = ' + CAST(@indx_id AS VARCHAR(50))
                                            + ')'

                                        EXEC sp_executesql @cmd_txt
                                    END
                            END

                        SELECT  @prtn_cnt = COUNT(*)
                        FROM    sys.partitions (NOLOCK)
                        WHERE   object_id = @obj_id
                                AND index_id = @indx_id 

                        IF @fill_fctr = 0 
                            SET @fill_fctr = 90
              
            /*******************************************************************************/
            /*If fragmentation is less than rebuild threshold, but greater than minimum    */
            /*threshold, reorganize the index.											   */
			/*                          BEGIN INDEX REORGANIZE                             */
			/*******************************************************************************/ 
                        IF ( @frag < 30.0
                             AND @frag >= 5.0
                           ) 
                            BEGIN

                                SET @beg_tm = GETDATE()
                                INSERT  INTO PCM_Maintenance.dbo.mntn_hst
                                        ( job_typ_txt ,
                                          srvr_nm ,
                                          btch_tm ,
                                          job_tm ,
                                          db_nm ,
                                          tbl_nm ,
                                          job_dur_amt ,
                                          frag_pct
                                        )
                                VALUES  ( 'Reorganize Index' ,
                                          @@SERVERNAME ,
                                          CONVERT(VARCHAR(25), @btch_tm, 100) ,
                                          @beg_tm ,
                                          @db_nm_var ,
                                          @obj_nm + '.' + @indx_nm ,
                                          NULL ,
                                          @frag
                                        )
                                SET @id = SCOPE_IDENTITY()

                                SET @cmd_txt = 'SET QUOTED_IDENTIFIER ON; SET NOCOUNT ON; ALTER INDEX '
                                    + QUOTENAME(@indx_nm, '[') + ' ON '
                                    + QUOTENAME(@db_nm_var, '[') + '.'
                                    + QUOTENAME(@schm_nm, '[') + '.'
                                    + QUOTENAME(@obj_nm, '[') + ' REORGANIZE' 

                                IF @prtn_cnt > 1 
                                    SET @cmd_txt = @cmd_txt + ' PARTITION='
                                        + CONVERT (CHAR, @prtn_nmbr) 

                            END
            /*******************************************************************************/
			/*                           END INDEX REORGANIZE                              */
			/*******************************************************************************/ 


			/*******************************************************************************/
			/*If fragmentation is greater than maximum threshold, rebuild the entire index */
			/*                            BEGIN INDEX REBUILD                              */
			/*******************************************************************************/
                        IF @frag >= 30.0 
                            BEGIN

                                SET @beg_tm = GETDATE()
                                INSERT  INTO PCM_Maintenance.dbo.mntn_hst
                                        ( job_typ_txt ,
                                          srvr_nm ,
                                          btch_tm ,
                                          job_tm ,
                                          db_nm ,
                                          tbl_nm ,
                                          job_dur_amt ,
                                          frag_pct
                                        )
                                VALUES  ( 'Rebuild Index' ,
                                          @@SERVERNAME ,
                                          CONVERT(VARCHAR(25), @btch_tm, 100) ,
                                          @beg_tm ,
                                          @db_nm_var ,
                                          @obj_nm + '.' + @indx_nm ,
                                          NULL ,
                                          @frag
                                        )
                                SET @id = SCOPE_IDENTITY()
				
                                SET @cmd_txt = 'ALTER INDEX '
                                    + QUOTENAME(@indx_nm, '[') + ' ON '
                                    + QUOTENAME(@db_nm_var, '[') + '.'
                                    + QUOTENAME(@schm_nm, '[') + '.'
                                    + QUOTENAME(@obj_nm, '[')
                                    + ' REBUILD WITH (FILLFACTOR = '
                                    + CAST(@fill_fctr AS VARCHAR)
                                    + ', MAXDOP = '
                                    + CONVERT(VARCHAR(2), @maxdop)

                                SELECT  @cmd_txt = @cmd_txt + ', ONLINE='
                                        + ISNULL(is_onln, 'YES')
                                FROM    #onln_op

                                SET @cmd_txt = @cmd_txt + ') ' 

                                IF @prtn_cnt > 1 
                                    SET @cmd_txt = @cmd_txt + ' PARTITION='
                                        + CONVERT (CHAR, @prtn_nmbr)

                                SET @cmd_txt = @cmd_txt + ' '

                            END

                        EXEC sp_executesql @cmd_txt 
            
                        UPDATE  PCM_Maintenance.dbo.mntn_hst
                        SET     job_dur_amt = DATEDIFF(ss, @beg_tm, GETDATE()) ,
                                rslt_txt = 'SUCCESS'
                        WHERE   row_id = @id
            /*****************************************************************************/
			/*                             END INDEX REBUILD                             */
			/*****************************************************************************/

                        FETCH NEXT FROM prtn_curs
					   INTO @db_id, @db_nm_var, @schm_nm, @obj_id, @obj_nm,
                            @indx_id, @indx_nm, @indx_typ_nm, @prtn_nmbr,
                            @frag, @fill_fctr--, @data_cmprs_opt_txt 

                    END 
		-- Close and deallocate the cursor.
                CLOSE prtn_curs 
                DEALLOCATE prtn_curs 

                TRUNCATE TABLE #work_to_do
        
        --DBCC Check for database if flagged for check.
                IF ( ( @dbcc_chk_flg = 1
                       AND @dbcc_chk = 1
                     )
                     OR @dbcc_chk = 1
                   ) 
                    BEGIN                          
                        EXEC PCM_Maintenance..up_dbcc_checkdb @db_nm_var
                    END
          

        /*******************************************************************************/
		/*Update database statistics. sp_updatestats automatically determines necessity*/
		/*                            BEGIN sp_updatestats                             */
		/*******************************************************************************/ 
                SET @beg_tm = GETDATE()
                INSERT  INTO PCM_Maintenance.dbo.mntn_hst
                        ( job_typ_txt ,
                          srvr_nm ,
                          btch_tm ,
                          job_tm ,
                          db_nm ,
                          tbl_nm ,
                          job_dur_amt
                        )
                VALUES  ( 'Update Statistics' ,
                          @@SERVERNAME ,
                          CONVERT(VARCHAR(25), @btch_tm, 100) ,
                          @beg_tm ,
                          @db_nm_var ,
                          @db_nm_var ,
                          NULL
                        )
                SET @id = SCOPE_IDENTITY()
        
                SET @cmd_txt = 'USE ' + QUOTENAME(@db_nm_var, '[') + '
					   EXEC sp_updatestats'
					   
                EXEC sp_executesql @cmd_txt 
					   
                UPDATE  PCM_Maintenance.dbo.mntn_hst
                SET     job_dur_amt = DATEDIFF(ss, @beg_tm, GETDATE()) ,
                        rslt_txt = 'SUCCESS'
                WHERE   row_id = @id
        /*******************************************************************************/
		/*                           END sp_updatestats                                */
		/*******************************************************************************/
					   
                FETCH NEXT FROM db_curs INTO @db_id, @db_nm_var, @dbcc_chk_flg

            END
        CLOSE db_curs
        DEALLOCATE db_curs

        DROP TABLE #work_to_do
        DROP TABLE #onln_op

        PRINT CONVERT(VARCHAR, GETDATE(), 120) + '  Complete'

    END  

GO
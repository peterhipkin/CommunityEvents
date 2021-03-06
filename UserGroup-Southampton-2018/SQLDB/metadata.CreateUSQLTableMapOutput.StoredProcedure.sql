USE [sdbamsdapdev001]
GO
/****** Object:  StoredProcedure [metadata].[CreateUSQLTableMapOutput]    Script Date: 06/06/2018 14:51:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [metadata].[CreateUSQLTableMapOutput]
	(
	@DataFlowName VARCHAR(255),
	@CodeSnippet NVARCHAR(MAX) OUTPUT,
	@DebugMode BIT = 0
	)
AS

SET NOCOUNT ON;

BEGIN
	/*for development:
	DECLARE @DataFlowName VARCHAR(255) = 'PatientsRawToBase'
	DECLARE @CodeSnippet NVARCHAR(MAX) 
	DECLARE @DebugMode BIT = 1
	*/

	--defensive checks
	IF NOT EXISTS
		(
		SELECT * FROM [metadata].[DataFlows] WHERE [DataFlowName] = @DataFlowName
		)
		BEGIN
			RAISERROR('Data flow name does not exist.',16,1);
			RETURN;
		END

	---------------------------------------------------------------------------------------------
	--									source table field list
	---------------------------------------------------------------------------------------------
	DECLARE @FieldList NVARCHAR(MAX) = ''

	SELECT
		@FieldList += '[' + [SourceAttribute] + '],' + CHAR(13) + CHAR(9) + CHAR(9)
	FROM
		[metadata].[CompleteMappings]
	WHERE
		[DataFlowName] = @DataFlowName

	SET @FieldList = [metadata].[RemoveLastComma](@FieldList)

	---------------------------------------------------------------------------------------------
	--									table path
	---------------------------------------------------------------------------------------------
	DECLARE @SourceObjectPath VARCHAR(128)

	SELECT
		@SourceObjectPath = QUOTENAME([SourcePrefix]) + '.' + QUOTENAME([SourceObject])
	FROM
		[metadata].[SourceObjects]
	WHERE
		[DataFlowName] = @DataFlowName	

	---------------------------------------------------------------------------------------------
	--									mappings
	---------------------------------------------------------------------------------------------
	DECLARE @Mappings NVARCHAR(MAX) = ''

	SELECT
		@Mappings += '[' + [SourceAttribute] + '] AS ' + [TargetAttribute] + ',' + CHAR(13) + CHAR(9) + CHAR(9)
	FROM
		[metadata].[CompleteMappings]
	WHERE
		[DataFlowName] = @DataFlowName

	SET @Mappings = [metadata].[RemoveLastComma](@Mappings)

	---------------------------------------------------------------------------------------------
	--									target attributes
	---------------------------------------------------------------------------------------------
	DECLARE @TargetFieldList NVARCHAR(MAX) = ''

	SELECT
		@TargetFieldList += '[' + [TargetAttribute] + '],' + CHAR(13) + CHAR(9)
	FROM
		[metadata].[CompleteMappings]
	WHERE
		[DataFlowName] = @DataFlowName

	SET @TargetFieldList = [metadata].[RemoveLastComma](@TargetFieldList)

	---------------------------------------------------------------------------------------------
	--									output trable
	---------------------------------------------------------------------------------------------
	DECLARE @TargetObjectType VARCHAR(128)
	DECLARE @TargetObjectAdditions VARCHAR(128)
	DECLARE @TargetObjectPath VARCHAR(128)

	SELECT
		@TargetObjectType = [metadata].[UpperCaseFirstChar]([TargetObjectType]),
		@TargetObjectAdditions = ISNULL([TargetObjectAdditions],''),
		@TargetObjectPath = '/' + [TargetPrefix] + '/' + [TargetObject] + '.' + [TargetObjectType]
	FROM
		[metadata].[TargetObjects]
	WHERE
		[DataFlowName] = @DataFlowName

	---------------------------------------------------------------------------------------------
	--								create final USQL script
	---------------------------------------------------------------------------------------------
	DECLARE @USQL NVARCHAR(MAX)

	SELECT
		@USQL = sp.[Script],
		@USQL = REPLACE(@USQL,'<##SourceObjectPath##>',@SourceObjectPath),
		@USQL = REPLACE(@USQL,'<##TargetObjectPath##>',@TargetObjectPath),
		@USQL = REPLACE(@USQL,'<##SourceAttributes##>',@FieldList),
		@USQL = REPLACE(@USQL,'<##SourceToTargetAttributes##>',@Mappings),
		@USQL = REPLACE(@USQL,'<##TargetObjectType##>',@TargetObjectType),
		@USQL = REPLACE(@USQL,'<##TargetObjectAdditions##>',@TargetObjectAdditions),
		@CodeSnippet = @USQL
	FROM
		[metadata].[ScriptParts] sp
		INNER JOIN [metadata].[DataFlows] df
			ON sp.[ScriptId] = df.[ScriptId]
	WHERE
		df.[DataFlowName] = @DataFlowName

	IF @DebugMode = 1 EXEC [dbo].[usp_PrintBig] @USQL

END
GO

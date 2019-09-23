CONTAINER=$1
/softwares/jasperstarter/bin/jasperstarter pr $PRECISION100_EXECUTION_CONTAINER_FOLDER/$CONTAINER/FAB-Parameter-Validation-Exception-Report.jrxml -f xlsx -t csv --data-file $PRECISION100_OPERATOR_SPOOL_FOLDER/T24_PARAMETERS_EXCEPTIONS_VIEW.csv --csv-columns TABLE_NAME,PARAMETER_NAME,C_VALUE,SOURCE_PARAMETER_VALUE,DEST_PARAMETER_VALUE,MESSAGE -P source='France UAT' target='France SEED' IS_IGNORE_PAGINATION=true -o $PRECISION100_OPERATOR_SPOOL_FOLDER/FAB-Parameter-Validation-Exception-Report
/softwares/jasperstarter/bin/jasperstarter pr $PRECISION100_EXECUTION_CONTAINER_FOLDER/$CONTAINER/FAB-Parameter-Validation-Exception-Report.jrxml -f xlsx -t csv --data-file $PRECISION100_OPERATOR_SPOOL_FOLDER/T24_PARAMETERS_MISMATCH_VIEW.csv --csv-columns TABLE_NAME,PARAMETER_NAME,C_VALUE,SOURCE_PARAMETER_VALUE,DEST_PARAMETER_VALUE,MESSAGE -P source='France UAT' target='France SEED' IS_IGNORE_PAGINATION=true -o $PRECISION100_OPERATOR_SPOOL_FOLDER/FAB-Parameter-Validation-Mismatch-Report

#region "  � Copyright 2005-06 to Marcos Meli - http://www.marcosmeli.com.ar" 

// Errors, suggestions, contributions, send a mail to: marcosdotnet[at]yahoo.com.ar.

#endregion

using System;
using System.Collections;
using System.ComponentModel;
using System.Data;

namespace FileHelpers.DataLink
{

	#region "  Delegates  "

	/// <summary>Delegate used by the <see cref="DatabaseStorage"/> to get the SQL for the insert or update statement.</summary>
	public delegate string InsertSqlHandler(object record);
	/// <summary>Delegate used by the <see cref="DatabaseStorage"/> to fill the values of a new record from the db (you only need to assing hte values.</summary>
	public delegate void FillRecordHandler(object record, object[] fieldValues);

	#endregion


	/// <summary>This class implements the <see cref="DataStorage"/> and is the base class for Data Base storages.</summary>
	[EditorBrowsable(EditorBrowsableState.Advanced)]
	public abstract class DatabaseStorage : DataStorage
	{

		RecordInfo mRecordInfo;
		#region Constructors

		/// <summary>Default constructor.</summary>
		/// <param name="recordType">The Record Type.</param>
		protected DatabaseStorage(Type recordType)
		{
			mRecordType = recordType;
			mRecordInfo = new RecordInfo(recordType);
		}
		#endregion

		#region RecordType

		private Type mRecordType;
		/// <summary>Returns the class that represent the records in the file.</summary>
		public sealed override Type RecordType
		{
			get{ return mRecordType; }
		}

		#endregion

		#region FillRecord
		/// <summary>This method recives the fields values as an array and must return a record object.</summary>
		/// <param name="fieldValues">The record fields values.</param>
		/// <returns>The record object.</returns>
		private object FillRecord(object[] fieldValues)
		{
			if (FillRecordCallback == null)
				throw new BadUsageException("You can�t extract records a null FillRecordCallback. Check the docs for help.");

			object res = mRecordInfo.CreateRecordObject();
			FillRecordCallback(res, fieldValues);
			return res;
		}
		#endregion

		#region SelectSql
		/// <summary>Must return the Select Sql used to Fetch the records to Extract.</summary>
		/// <returns>The SQL statement.</returns>
		private string GetSelectSql()
		{
			if (mSelectSql == null || mSelectSql == string.Empty)
				throw new BadUsageException("The SelectSql property is empty, please set it before try to get the records.");

			return mSelectSql;
		}

		private string mSelectSql = string.Empty;

		/// <summary>Indicates the Sql statment used to get the records.</summary>
		public string SelectSql
		{
			get { return mSelectSql; }
			set { mSelectSql = value; }
		}

		#endregion

		#region GetInsertSql

		/// <summary>Must return a SQL string with the insert statement for the records.</summary>
		/// <param name="record">The record to insert.</param>
		/// <returns>The Sql string to used to insert the record.</returns>
		private string GetInsertSql(object record)
		{
			if (mInsertSqlCallback == null)
				throw new BadUsageException("You can�t insert records with a null GetInsertSqlCallback. Check the docs for help.");

			return mInsertSqlCallback(record);
		}

		#endregion

		#region MustOverride Methods
		
		/// <summary>Must create an abstract connection object.</summary>
		/// <returns>An Abstract Connection Object.</returns>
		protected abstract IDbConnection CreateConnection();

		/// <summary>Must create an abstract command object.</summary>
		/// <returns>An Abstract Command Object.</returns>
		protected abstract IDbCommand CreateCommand();
		
		#endregion

		#region Connections

		private IDbConnection mConn;

		private void InitConnection()
		{
			if (mConn == null)
			{
				mConn = CreateConnection();
			}
		}

		#endregion

		#region "  SelectRecords  "

		/// <summary>Must Return the records from the DataSource (DB, Excel, etc)</summary>
		/// <returns>The extracted records.</returns>
		public override object[] ExtractRecords()
		{
			InitConnection();

			ArrayList res = new ArrayList();

			try
			{
				if (mConn.State != ConnectionState.Open)
					mConn.Open();

				IDbCommand command = CreateCommand();
				command.Connection = mConn;
				command.CommandText = GetSelectSql();

				IDataReader reader = command.ExecuteReader();

				object currentObj;
				object[] values = new object[reader.FieldCount];

				ProgressHelper.Notify(mNotifyHandler, mProgressMode, 0, -1);

				int recordNumber = 0;

				while (reader.Read())
				{
					recordNumber++;
					ProgressHelper.Notify(mNotifyHandler, mProgressMode, recordNumber, -1);


					reader.GetValues(values);
					currentObj = FillRecord(values);
					res.Add(currentObj);
				}

				reader.Close();
			}
			finally
			{
				if (mConn.State != ConnectionState.Closed)
					mConn.Close();
			}

			return (object[]) res.ToArray(mRecordType);
			
		}

		#endregion

		#region ExecuteInBatch

		/// <summary>Indicates if the underlaying Conexion allow more than one instruction per execute.</summary>
		protected virtual bool ExecuteInBatch
		{
			get { return false; }
		}

		#endregion

		#region "  InsertRecords  "

		/// <summary>Must Insert the records in a DataSource (DB, Excel, etc)</summary>
		/// <param name="records">The records to insert.</param>
		public override void InsertRecords(object[] records)
		{
			try
			{
				InitConnection();

				if (mConn.State != ConnectionState.Open)
					mConn.Open();

				string SQL = String.Empty;

				ProgressHelper.Notify(mNotifyHandler, mProgressMode, 0, records.Length);
				int recordNumber = 0;
				int batchCount = 0;

                foreach (object record in records)
				{
					// Insert Logic Here, must check duplicates
					recordNumber++;
					batchCount++;
					ProgressHelper.Notify(mNotifyHandler, mProgressMode, recordNumber, records.Length);

					SQL += GetInsertSql(record) + " ";

					if (ExecuteInBatch)
					{
						if (batchCount >= mExecuteInBatchSize)
						{
							ExecuteAndLeaveOpen(SQL);
							SQL = String.Empty;
							batchCount = 0;
						}
					}
					else
					{
						ExecuteAndLeaveOpen(SQL);
						SQL = String.Empty;
					}

				}
				if (SQL != null && SQL.Length != 0)
				{
					ExecuteAndLeaveOpen(SQL);
					SQL = String.Empty;
				}
			}
			finally
			{
				if (mConn.State != ConnectionState.Closed)
					mConn.Close();
			}

		}

		#endregion

		#region "  ExecuteNonQuery (HelperMethods) "

		private int ExecuteAndLeaveOpen(string sql)
		{
			InitConnection();

			IDbCommand command = CreateCommand();
			command.Connection = mConn;
			command.CommandText = sql;

			return command.ExecuteNonQuery();
		}

		private int ExecuteAndClose(string sql)
		{
			int res = -1;

			InitConnection();

			try
			{
				if (mConn.State != ConnectionState.Open)
					mConn.Open();

				IDbCommand command = CreateCommand();
				command.Connection = mConn;
				command.CommandText = sql;

				res = command.ExecuteNonQuery();
			}
			finally
			{
				if (mConn.State != ConnectionState.Closed)
					mConn.Close();
			}

			return res;
		}

		#endregion

		#region InsertSqlCallback

		private InsertSqlHandler mInsertSqlCallback;

		/// <summary>Delegate used to get the SQL for the insert or update statement.</summary>
		public InsertSqlHandler InsertSqlCallback
		{
			get { return mInsertSqlCallback; }
			set { mInsertSqlCallback = value; }
		}

		#endregion

		#region FillRecordCallback

		private FillRecordHandler mFillRecordCallback;
		/// <summary>Delegate used to fill the values of a new record from the db.</summary>
		public FillRecordHandler FillRecordCallback
		{
			get { return mFillRecordCallback; }
			set { mFillRecordCallback = value; }
		}

		#endregion

		#region ExecuteInBatchSize

		private int mExecuteInBatchSize = 100;

		/// <summary>Indicates the max number of instruction of each execution. High numbers help reduce the round trips to the db and so help tp improve performance.</summary>
		public int ExecuteInBatchSize
		{
			get { return mExecuteInBatchSize; }
			set
			{
				if (value < 1)
					throw new ArgumentException("ExecuteInBatchSize","ExecuteInBatchSize must be >= 1");

				mExecuteInBatchSize = value;
			}
		}
		#endregion

	}
}
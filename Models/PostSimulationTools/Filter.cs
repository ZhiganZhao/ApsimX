﻿namespace Models.PostSimulationTools
{
    using Models.Core;
    using Models.Core.Run;
    using Models.Storage;
    using System;
    using System.Data;

    /// <summary>
    /// This is a post simulation tool that lets the user filter the rows of a source data table.
    /// </summary>
    [ViewName("UserInterface.Views.GridView")]
    [PresenterName("UserInterface.Presenters.PropertyPresenter")]
    [ValidParent(ParentType = typeof(DataStore))]
    [Serializable]
    public class Filter : Model, IPostSimulationTool
    {
        /// <summary>Link to datastore</summary>
        [Link]
        private IDataStore dataStore = null;

        /// <summary>The name of the source table name.</summary>
        [Description("Name of source table")]
        [Display(Type = DisplayType.TableName)]
        public string SourceTableName { get; set; }

        /// <summary>The row filter.</summary>
        [Description("Row filter")]
        [Display]
        public string FilterString { get; set; }

        /// <summary>Main run method for performing our calculations and storing data.</summary>
        public void Run()
        {
            if (string.IsNullOrEmpty(FilterString))
                throw new Exception($"Empty filter found in {Name}");

            var sourceData = dataStore.Reader.GetData(SourceTableName);
            if (sourceData != null)
            {
                var view = new DataView(sourceData);
                view.RowFilter = FilterString;

                // Give the new data table to the data store.
                var table = view.ToTable();
                table.TableName = Name;
                dataStore.Writer.WriteTable(table);
            }
        }
    }
}

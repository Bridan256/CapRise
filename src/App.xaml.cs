using System;
using Microsoft.Maui.Controls;

namespace CapRise
{
    public partial class App : Application
    {
        public App()
        {
            InitializeComponent();
            MainPage = new MainPage();
        }
    }
}
On Ubuntu 24 dark theme is different for snaps (nautilus etc) and different for normal apps.  

## nautilus does not preserve dark mode (gtk-4.0 snap)
you need to enable dark theme [[1]\] in your settings to 1
```
$ vim /home/dimipet/.config/gtk-4.0/settings.ini

gtk-application-prefer-dark-theme=1

```
For more info on the proble check [[2]\] [[3]\]  



# references
[1] https://www.gnome-look.org/p/1424967/  
[2] https://bugs.launchpad.net/ubuntu/+source/nautilus/+bug/2064566  
[3] https://blogs.gnome.org/alatiera/2021/09/18/the-truth-they-are-not-telling-you-about-themes/  

[1]: https://www.gnome-look.org/p/1424967/  
[2]: https://bugs.launchpad.net/ubuntu/+source/nautilus/+bug/2064566  
[3]: https://blogs.gnome.org/alatiera/2021/09/18/the-truth-they-are-not-telling-you-about-themes/  

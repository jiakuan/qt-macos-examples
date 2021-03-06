/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: https://www.qt.io/licensing/
**
** This file is part of the examples of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:BSD$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see https://www.qt.io/terms-conditions. For further
** information use the contact form at https://www.qt.io/contact-us.
**
** BSD License Usage
** Alternatively, you may use this file under the terms of the BSD license
** as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**     contributors may be used to endorse or promote products derived
**     from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

#import <AppKit/AppKit.h>
#include <QtGui>
#include <qtcontent.h>

// A NSViewController that controls a programatically created view
@interface ProgramaticViewController : NSViewController
@end

@implementation ProgramaticViewController
- (id)initWithView:(NSView *)aView
{
    self = [self initWithNibName:nil bundle:nil];
    self.view = aView;
    return self;
}
@end

// A QWindow subclass that shows a popover on mouse release
class ClickWindow : public QRasterWindow
{
public:
    ClickWindow()
    {
        setTitle("QWindow in NSPopover example");

        // Create native popover
        m_popover = [[NSPopover alloc] init];
        [m_popover setContentSize:NSMakeSize(250, 200)];
        [m_popover setBehavior:NSPopoverBehaviorTransient];
        [m_popover setAnimates:YES];

        // Create popover content window
        m_window.reset(new PopoverCheckeredWindow());

        // Close popover on PopoverCheckeredWindow close signal
        connect(m_window.get(), &PopoverCheckeredWindow::closePopup, [=]() {
            [m_popover close];
        });

        // Assign the Qt window to the popoper via view controller
        NSView *popoverView = (__bridge NSView *)reinterpret_cast<void *>(m_window->winId());
        [m_popover setContentViewController:[[ProgramaticViewController alloc] initWithView:popoverView]];
        m_window->show();
    }

    void mousePressEvent(QMouseEvent *event)
    {
        // Close currently open popover (if any)
        [m_popover close];

        // Show popover on the ClickWindow window at mouse position;
        NSView *thisView = (__bridge NSView *)reinterpret_cast<void *>(winId());
        NSRect position = CGRectMake(event->localPos().x(), event->localPos().y(), 1, 1);
        [m_popover showRelativeToRect:position ofView:thisView preferredEdge:NSMaxYEdge];
    }

    void paintEvent(QPaintEvent *event)
    {
        QString message = "Click to display popover";
        QPainter p(this);
        p.fillRect(event->rect(), QColor(240, 240, 240, 255));
        p.setPen(QPen(QColor(40, 40, 40, 200)));
        p.drawText(event->rect(), Qt::AlignCenter, message);
    }

private:
    std::unique_ptr<PopoverCheckeredWindow> m_window;
    NSPopover *m_popover;
};

int main(int argc, char **argv)
{
    QGuiApplication app(argc, argv);

    ClickWindow window;
    window.resize(400, 400);
    window.show();

    return app.exec();
}

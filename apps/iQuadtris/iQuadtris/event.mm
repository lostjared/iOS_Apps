
#ifdef HAVE_CONFIG_H
#include<config.h>
#endif
#include"cmx_event.h"
#include<iostream>

namespace cmx {
	namespace event {

		std::deque<Event > event_que;

		bool Event::procEvent() {


			return false;
		}
        unsigned int createTimer(unsigned int interval, timerFunc t) {
          
            return 0;
        }
        void stopTimer(unsigned int value) {
            
        }
	}
}


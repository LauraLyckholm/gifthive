import { Button } from "../../components/elements/Button/Button";
import { useGiftStore } from "../../stores/useGiftStore";
import { useParams, useNavigate } from "react-router-dom";
import { customSwal } from "../../utils/customSwal";
import { DatePicker } from "@mui/x-date-pickers/DatePicker";
import dayjs from "dayjs";
import EditCalendarRoundedIcon from "@mui/icons-material/EditCalendarRounded";
import "./create.css";
import { useEffect } from "react";

// Component for updating a gift
export const UpdateGiftInfo = () => {
    const { giftName, setGiftName, updateGift, tags, setTags, dueDate, setDueDate, getHives, hives } = useGiftStore();
    const { id, giftId } = useParams();
    const hiveId = id;
    const giftIdParam = giftId;
    const navigate = useNavigate();

    // Function to handle navigation back to the hive
    const handleOnclickNavigation = () => {
        navigate(`/hives/${hiveId}`)
    };

    // Fetches the hives when the component mounts
    useEffect(() => {
        getHives();
    }, []);

    // Fetches the gift when the component mounts and sets the gift name and tags to the current values
    useEffect(() => {
        if (hives && hives.length > 0) {
            hives.map((hive) => {
                hive.gifts.map((gift) => {
                    if (gift._id === giftIdParam) {
                        setGiftName(gift.gift);
                        setTags(gift.tags.join(", ")); // Assuming tags is an array
                    }
                });
            });
        }
    }, []);

    // function to handle adding a new gift
    const handleUpdateGift = async (event) => {
        event.preventDefault();

        let giftData = {
            id: giftIdParam,
        };

        if (giftName.trim()) {
            giftData.gift = giftName;
        }

        if (tags.trim()) {
            // Formats the tags so that they are saved as an array with several strings instead of one string. Filters out empty tags
            giftData.tags = tags.split(",")
                .map(tag => tag.trim())
                .filter(tag => tag !== "");
        }

        // Check if dueDate is not set
        if (!dueDate) {
            giftData.dueDate = null;  // Set dueDate to null to remove it
        } else if (!dayjs(dueDate).isBefore(dayjs())) {
            giftData.dueDate = dueDate;  // Set dueDate if it's valid
        } else {
            customSwal.fire({
                title: "Oops...",
                text: "The due date must be in the future!",
                icon: "error",
                confirmButtonText: "OK",
            });
            return;
        }

        try {
            await updateGift(giftData);
            setGiftName("");
            setTags("");
            setDueDate(null);

            // Alerts to the user that the gift has been created and gives them the choice to either add another gift or go back to their hive
            customSwal.fire({
                title: "Weee!",
                text: "Gift successfully updated! 🎁",
                icon: "success",
                confirmButtonText: "Back to my hive!",
            }).then((result) => {
                if (result.isConfirmed) {
                    setGiftName("");
                    setTags("");
                    setDueDate(null);
                    navigate(`/hives/${hiveId}`);
                }
            });
        } catch (error) {
            console.error("There was an error =>", error);
        }
    }

    return (
        <section>
            <h1>Update gift</h1>
            <form className="form-wrapper" onSubmit={handleUpdateGift}>
                <div className="form-group">
                    <label htmlFor="giftName">Gift name</label>
                    <input
                        type="text"
                        id="giftName"
                        placeholder="e.g. New phone"
                        value={giftName}
                        onChange={(e) => setGiftName(e.target.value)}
                        required />
                </div>
                <div className="form-group">
                    <label htmlFor="tags">Tags (separated by comma)</label>
                    <input
                        type="text"
                        id="tags"
                        placeholder="e.g. Christmas, 2024 "
                        value={tags}
                        onChange={(e) => setTags(e.target.value)}
                        required />
                </div>
                <div className="form-group">
                    <label htmlFor="dueDate">Due date</label>
                    <DatePicker
                        className="customDatePickerInput"
                        id="dueDate"
                        value={dueDate ? dayjs(dueDate) : null}
                        onChange={setDueDate}
                        slots={{
                            openPickerIcon: EditCalendarRoundedIcon,
                        }}
                        slotProps={{
                            openPickerButton: { color: "primary" },
                            textField: {
                                variant: "outlined",
                                fullWidth: true,
                            },
                        }}
                    />
                </div>
            </form>

            <div className="btns">
                <Button handleOnClick={handleUpdateGift} className={"primary"} btnText={"Update gift"} />
                <Button className={"secondary"} handleOnClick={handleOnclickNavigation} btnText={"Back to hive"} />
            </div>
        </section>
    )
}
